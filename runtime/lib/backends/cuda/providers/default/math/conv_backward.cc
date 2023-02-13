//===- conv_backward.cc ---------------------------------------*--- C++ -*-===//
//
// Copyright 2022 ByteDance Ltd. and/or its affiliates. All rights reserved.
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//===----------------------------------------------------------------------===//

#include "./conv_backward.h"
#include "brt/backends/cuda/device/common/cuda_call.h"
#include "brt/backends/cuda/device/common/dtype.h"
#include "brt/backends/cuda/device/common/util.h"
#include "brt/backends/cuda/device/cuda_work_queue.h"
#include "brt/backends/cuda/providers/default/cudnn_helper.h"
#include "brt/backends/cuda/providers/default/math/helper.h"
#include "brt/core/common/common.h"
#include "brt/core/context/execution_context.h"
#include "brt/core/context/execution_frame.h"
#include "brt/core/ir/ir.h"
#include "brt/core/ir/util.h"
#include <cuda_fp16.h>
#include <cudnn.h>

using namespace brt;
using namespace brt::common;
using namespace brt::cuda;
using namespace brt::ir;

namespace brt {
namespace cuda {

//===----------------------------------------------------------------------===//
// ConvBackwardData
//===----------------------------------------------------------------------===//

template <typename T>
ConvBackwardDataImpl<T>::ConvBackwardDataImpl(const OpAccessor &accessor) {
  auto shape_grad_output = accessor.GetArgShape(0);
  auto shape_filter = accessor.GetArgShape(1);
  auto shape_grad_input = accessor.GetArgShape(2);
  cudnnTensorFormat_t format;
  cudnnDataType_t type = ConvertBRTDTypeToCudnnDtype(dtype_enum_v<T>);
  int64_t N, iC, iH, iW, oC, oH, oW, kH, kW;
  int64_t strideH, strideW, paddingH, paddingW, dilationH, dilationW;
  conv::handleConvParam(accessor, shape_grad_input, shape_filter,
                        shape_grad_output, N, iC, iH, iW, oC, oH, oW, kH, kW,
                        strideH, strideW, paddingH, paddingW, dilationH,
                        dilationW, format);
  BRT_CUDNN_CHECK(cudnnCreateTensorDescriptor(&grad_input_descriptor));
  BRT_CUDNN_CHECK(cudnnSetTensor4dDescriptor(grad_input_descriptor,
                                             /*format=*/format,
                                             /*dataType=*/type,
                                             /*batch_size=*/N,
                                             /*channels=*/iC,
                                             /*image_height=*/iH,
                                             /*image_width=*/iW));
  BRT_CUDNN_CHECK(cudnnCreateTensorDescriptor(&grad_output_descriptor));
  BRT_CUDNN_CHECK(cudnnSetTensor4dDescriptor(grad_output_descriptor,
                                             /*format=*/format,
                                             /*dataType=*/type,
                                             /*batch_size=*/N,
                                             /*channels=*/oC,
                                             /*image_height=*/oH,
                                             /*image_width=*/oW));
  BRT_CUDNN_CHECK(cudnnCreateFilterDescriptor(&filter_descriptor));
  BRT_CUDNN_CHECK(cudnnSetFilter4dDescriptor(filter_descriptor,
                                             /*dataType=*/type,
                                             /*format=*/format,
                                             /*out_channels=*/oC,
                                             /*in_channels=*/iC,
                                             /*kernel_height=*/kH,
                                             /*kernel_width=*/kW));
  BRT_CUDNN_CHECK(cudnnCreateConvolutionDescriptor(&convolution_descriptor));
  BRT_CUDNN_CHECK(
      cudnnSetConvolution2dDescriptor(convolution_descriptor,
                                      /*pad_h=*/paddingH,
                                      /*pad_w=*/paddingW,
                                      /*u=*/strideH,
                                      /*v=*/strideW,
                                      /*dilation_h=*/dilationH,
                                      /*dilation_w=*/dilationW,
                                      /*mode=*/CUDNN_CROSS_CORRELATION,
                                      /*computeType=*/CUDNN_DATA_FLOAT));
  if (format == CUDNN_TENSOR_NHWC && dtype_enum_v<T> == DTypeEnum::Float16) {
    BRT_CUDNN_CHECK(cudnnSetConvolutionMathType(convolution_descriptor,
                                                CUDNN_TENSOR_OP_MATH));
  }
}

template <typename T>
void ConvBackwardDataImpl<T>::Execute(const T *diff, const T *filter, T *grad,
                                      void *workspace, cudnnHandle_t handle,
                                      cudaStream_t /*stream*/) {
  BRT_CUDNN_CHECK(cudnnConvolutionBackwardData(
      handle, &alpha, filter_descriptor, filter, grad_output_descriptor, diff,
      convolution_descriptor, perf.algo, workspace, perf.memory, &beta,
      grad_input_descriptor, grad));
}

template <typename T>
size_t ConvBackwardDataImpl<T>::GetWorkspaceSize(const ExecutionContext &ctx) {
  BRT_ENFORCE(has_perf_result == false);
  has_perf_result = true;
  auto handle = GetOrCreateCuDNNHandle(ctx);
  int returnedAlgoCount = 0;
  BRT_CUDNN_CHECK(cudnnFindConvolutionBackwardDataAlgorithm(
      handle, filter_descriptor, grad_output_descriptor, convolution_descriptor,
      grad_input_descriptor,
      /*requestedAlgoCount=*/1, &returnedAlgoCount, &perf));
  BRT_ENFORCE(returnedAlgoCount == 1);
  return perf.memory;
}

template <typename T> ConvBackwardDataImpl<T>::~ConvBackwardDataImpl() {
  BRT_CUDNN_CHECK(cudnnDestroyTensorDescriptor(grad_input_descriptor));
  BRT_CUDNN_CHECK(cudnnDestroyTensorDescriptor(grad_output_descriptor));
  BRT_CUDNN_CHECK(cudnnDestroyFilterDescriptor(filter_descriptor));
  BRT_CUDNN_CHECK(cudnnDestroyConvolutionDescriptor(convolution_descriptor));
}

// instantiate
template class ConvBackwardDataImpl<float>;
template class ConvBackwardDataImpl<__half>;

//===----------------------------------------------------------------------===//
// ConvBackwardFilter
//===----------------------------------------------------------------------===//

template <typename T>
ConvBackwardFilterImpl<T>::ConvBackwardFilterImpl(const OpAccessor &accessor) {
  auto shape_input = accessor.GetArgShape(0);
  auto shape_grad_output = accessor.GetArgShape(1);
  auto shape_grad_filter = accessor.GetArgShape(2);
  cudnnTensorFormat_t format;
  cudnnDataType_t type = ConvertBRTDTypeToCudnnDtype(dtype_enum_v<T>);
  int64_t N, iC, iH, iW, oC, oH, oW, kH, kW;
  int64_t strideH, strideW, paddingH, paddingW, dilationH, dilationW;
  conv::handleConvParam(accessor, shape_input, shape_grad_filter,
                        shape_grad_output, N, iC, iH, iW, oC, oH, oW, kH, kW,
                        strideH, strideW, paddingH, paddingW, dilationH,
                        dilationW, format);
  BRT_CUDNN_CHECK(cudnnCreateTensorDescriptor(&input_descriptor));
  BRT_CUDNN_CHECK(cudnnSetTensor4dDescriptor(input_descriptor,
                                             /*format=*/format,
                                             /*dataType=*/type,
                                             /*batch_size=*/N,
                                             /*channels=*/iC,
                                             /*image_height=*/iH,
                                             /*image_width=*/iW));
  BRT_CUDNN_CHECK(cudnnCreateTensorDescriptor(&grad_output_descriptor));
  BRT_CUDNN_CHECK(cudnnSetTensor4dDescriptor(grad_output_descriptor,
                                             /*format=*/format,
                                             /*dataType=*/type,
                                             /*batch_size=*/N,
                                             /*channels=*/oC,
                                             /*image_height=*/oH,
                                             /*image_width=*/oW));
  BRT_CUDNN_CHECK(cudnnCreateFilterDescriptor(&grad_filter_descriptor));
  BRT_CUDNN_CHECK(cudnnSetFilter4dDescriptor(grad_filter_descriptor,
                                             /*dataType=*/type,
                                             /*format=*/format,
                                             /*out_channels=*/oC,
                                             /*in_channels=*/iC,
                                             /*kernel_height=*/kH,
                                             /*kernel_width=*/kW));
  BRT_CUDNN_CHECK(cudnnCreateConvolutionDescriptor(&convolution_descriptor));
  BRT_CUDNN_CHECK(
      cudnnSetConvolution2dDescriptor(convolution_descriptor,
                                      /*pad_h=*/paddingH,
                                      /*pad_w=*/paddingW,
                                      /*u=*/strideH,
                                      /*v=*/strideW,
                                      /*dilation_h=*/dilationH,
                                      /*dilation_w=*/dilationW,
                                      /*mode=*/CUDNN_CROSS_CORRELATION,
                                      /*computeType=*/CUDNN_DATA_FLOAT));
  BRT_CUDNN_CHECK(cudnnSetConvolutionMathType(convolution_descriptor,
                                              CUDNN_TENSOR_OP_MATH));
}

template <typename T>
void ConvBackwardFilterImpl<T>::Execute(const T *input, const T *diff, T *grad,
                                        void *workspace, cudnnHandle_t handle,
                                        cudaStream_t /*stream*/) {
  BRT_CUDNN_CHECK(cudnnConvolutionBackwardFilter(
      handle, &alpha, input_descriptor, input, grad_output_descriptor, diff,
      convolution_descriptor, perf.algo, workspace, perf.memory, &beta,
      grad_filter_descriptor, grad));
}

template <typename T>
size_t
ConvBackwardFilterImpl<T>::GetWorkspaceSize(const ExecutionContext &ctx) {
  BRT_ENFORCE(has_perf_result == false);
  has_perf_result = true;
  auto handle = GetOrCreateCuDNNHandle(ctx);
  int returnedAlgoCount = 0;
  BRT_CUDNN_CHECK(cudnnFindConvolutionBackwardFilterAlgorithm(
      handle, input_descriptor, grad_output_descriptor, convolution_descriptor,
      grad_filter_descriptor,
      /*requestedAlgoCount=*/1, &returnedAlgoCount, &perf));
  BRT_ENFORCE(returnedAlgoCount == 1);
  return perf.memory;
}

template <typename T> ConvBackwardFilterImpl<T>::~ConvBackwardFilterImpl() {
  BRT_CUDNN_CHECK(cudnnDestroyTensorDescriptor(input_descriptor));
  BRT_CUDNN_CHECK(cudnnDestroyTensorDescriptor(grad_output_descriptor));
  BRT_CUDNN_CHECK(cudnnDestroyFilterDescriptor(grad_filter_descriptor));
  BRT_CUDNN_CHECK(cudnnDestroyConvolutionDescriptor(convolution_descriptor));
}

// instantiate
template class ConvBackwardFilterImpl<float>;
template class ConvBackwardFilterImpl<__half>;

} // namespace cuda
} // namespace brt