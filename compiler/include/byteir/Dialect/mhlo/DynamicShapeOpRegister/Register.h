//===- Register.h ---------------------------------------------*--- C++ -*-===//
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

#ifndef BYTEIR_DIALECT_MHLO_DYNAMICSHAPEOPREGISTER_REGISTER_H
#define BYTEIR_DIALECT_MHLO_DYNAMICSHAPEOPREGISTER_REGISTER_H

#include "byteir/Dialect/mhlo/Util/ShapeInferUtil.h"
#include "llvm/ADT/StringRef.h"

namespace mlir {
//===----------------------------------------------------------------------===//
// StaticShapeInfer Registration
//===----------------------------------------------------------------------===//
void registerConvolutionInferReturnTypeComponents();
void registerDotGeneralInferReturnTypeComponents();
void registerDynamicBroadcastInDimInferReturnTypeComponents();
void registerDynamicReshapeInferReturnTypeComponents();
void registerRealDynamicSliceInferReturnTypeComponents();
void registerReduceInferReturnTypeComponents();
void registerSoftmaxInferReturnTypeComponents();
void registerTorchIndexSelectInferReturnTypeComponents();

inline void registerAllMhloInferReturnTypeComponents() {
  registerConvolutionInferReturnTypeComponents();
  registerDotGeneralInferReturnTypeComponents();
  registerDynamicBroadcastInDimInferReturnTypeComponents();
  registerDynamicReshapeInferReturnTypeComponents();
  registerRealDynamicSliceInferReturnTypeComponents();
  registerReduceInferReturnTypeComponents();
  registerSoftmaxInferReturnTypeComponents();
  registerTorchIndexSelectInferReturnTypeComponents();
}

//===----------------------------------------------------------------------===//
// BoundedShapeInfer Registration
//===----------------------------------------------------------------------===//
void registerDynamicPartitionInferBoundedReturnTypeComponents();
void registerNonZeroInferBoundedReturnTypeComponents();
void registerWhereInferBoundedReturnTypeComponents();

inline void registerAllMhloInferBoundedReturnTypeComponents() {
  registerDynamicPartitionInferBoundedReturnTypeComponents();
  registerNonZeroInferBoundedReturnTypeComponents();
  registerWhereInferBoundedReturnTypeComponents();
}

//===----------------------------------------------------------------------===//
// ShapeReification Registration
//===----------------------------------------------------------------------===//
void registerDotReifyReturnTypeShapes();
void registerDynamicStitchReifyReturnTypeShapes();
void registerDynamicMaskStitchReifyReturnTypeShapes();
void registerDynamicBroadcastInDimReifyReturnTypeShapes();
void registerSoftmaxReifyReturnTypeShapes();
void registerTorchIndexSelectReifyReturnTypeShapes();

inline void registerAllMhloReifyReturnTypeShapes() {
  registerDotReifyReturnTypeShapes();
  registerDynamicStitchReifyReturnTypeShapes();
  registerDynamicMaskStitchReifyReturnTypeShapes();
  registerDynamicBroadcastInDimReifyReturnTypeShapes();
  registerSoftmaxReifyReturnTypeShapes();
  registerTorchIndexSelectReifyReturnTypeShapes();
}

//===----------------------------------------------------------------------===//
// ShapeConstraint Registration
//===----------------------------------------------------------------------===//
void registerDotGeneralShapeConstraints();
void registerDynamicPartitionShapeConstraints();
void registerDynamicReshapeShapeConstraints();
void registerEinsumShapeConstraints();
void registerReshapeShapeConstraints();

inline void registerAllMhloShapeConstraints() {
  registerDotGeneralShapeConstraints();
  registerDynamicPartitionShapeConstraints();
  registerDynamicReshapeShapeConstraints();
  registerEinsumShapeConstraints();
  registerReshapeShapeConstraints();
}

} // namespace mlir

#endif // BYTEIR_DIALECT_MHLO_DYNAMICSHAPEOPREGISTER_REGISTER_H
