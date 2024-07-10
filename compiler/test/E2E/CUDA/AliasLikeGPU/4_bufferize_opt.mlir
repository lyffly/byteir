// RUN: byteir-opt %s -byteir-bufferize-opt | FileCheck %s

// CHECK-LABEL: func.func private @Unknown

#map = affine_map<() -> ()>
module {
  func.func private @Unknown0(%arg0: tensor<128x2x100xf32>, %arg1: tensor<128x2x100xf32>) -> tensor<128x2x100xf32> attributes {__byteir_elementwise_fusion__} {
    %c100 = arith.constant 100 : index
    %c2 = arith.constant 2 : index
    %c1 = arith.constant 1 : index
    %c128 = arith.constant 128 : index
    %c0 = arith.constant 0 : index
    %0 = tensor.empty() : tensor<128x2x100xf32>
    %1 = scf.for %arg2 = %c0 to %c128 step %c1 iter_args(%arg3 = %0) -> (tensor<128x2x100xf32>) {
      %2 = scf.for %arg4 = %c0 to %c2 step %c1 iter_args(%arg5 = %arg3) -> (tensor<128x2x100xf32>) {
        %3 = scf.for %arg6 = %c0 to %c100 step %c1 iter_args(%arg7 = %arg5) -> (tensor<128x2x100xf32>) {
          %extracted_slice = tensor.extract_slice %arg0[%arg2, %arg4, %arg6] [1, 1, 1] [1, 1, 1] : tensor<128x2x100xf32> to tensor<f32>
          %extracted_slice_0 = tensor.extract_slice %arg1[%arg2, %arg4, %arg6] [1, 1, 1] [1, 1, 1] : tensor<128x2x100xf32> to tensor<f32>
          %4 = tensor.empty() : tensor<f32>
          %5 = linalg.generic {indexing_maps = [#map, #map, #map], iterator_types = []} ins(%extracted_slice, %extracted_slice_0 : tensor<f32>, tensor<f32>) outs(%4 : tensor<f32>) {
          ^bb0(%in: f32, %in_1: f32, %out: f32):
            %6 = arith.addf %in, %in_1 : f32
            linalg.yield %6 : f32
          } -> tensor<f32>
          %inserted_slice = tensor.insert_slice %5 into %arg7[%arg2, %arg4, %arg6] [1, 1, 1] [1, 1, 1] : tensor<f32> into tensor<128x2x100xf32>
          scf.yield %inserted_slice : tensor<128x2x100xf32>
        }
        scf.yield %3 : tensor<128x2x100xf32>
      }
      scf.yield %2 : tensor<128x2x100xf32>
    }
    return %1 : tensor<128x2x100xf32>
  }
  func.func @main(%arg0: tensor<512x200xf32>, %arg1: tensor<512x2x100xf32>) -> tensor<128x2x100xf32> attributes {__placeholder__byre.entry_point} {
    %extracted_slice = tensor.extract_slice %arg0[0, 0] [128, 200] [1, 1] : tensor<512x200xf32> to tensor<128x200xf32>
    %extracted_slice_0 = tensor.extract_slice %arg0[10, 0] [128, 200] [1, 1] : tensor<512x200xf32> to tensor<128x200xf32>
    %expanded = tensor.expand_shape %extracted_slice [[0], [1, 2]] output_shape [128, 2, 100] : tensor<128x200xf32> into tensor<128x2x100xf32>
    %expanded_1 = tensor.expand_shape %extracted_slice_0 [[0], [1, 2]] output_shape [128, 2, 100] : tensor<128x200xf32> into tensor<128x2x100xf32>
    %0 = call @Unknown0(%expanded, %expanded_1) : (tensor<128x2x100xf32>, tensor<128x2x100xf32>) -> tensor<128x2x100xf32>
    return %0 : tensor<128x2x100xf32>
  }
}