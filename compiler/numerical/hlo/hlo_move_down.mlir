// RUN: byteir-opt %s -hlo-move-down -o %t
// RUN: FileCheck %s < %t
// RUN: python3 %S/numerical_test.py %s %t

func.func @transpose_move_down_binary_const(%arg0 : tensor<1x2x3xf32>) -> tensor<3x1x2xf32> {
    %0 = mhlo.constant dense<[[[1.000000e+00, 2.000000e+00]], [[3.000000e+00, 4.000000e+00]], [[5.000000e+00, 6.000000e+00]]]> : tensor<3x1x2xf32>
    %1 = "mhlo.transpose"(%arg0) {permutation = dense<[2, 0, 1]> : tensor<3xi64>} : (tensor<1x2x3xf32>) -> tensor<3x1x2xf32>
    %2 = mhlo.add %1, %0 : tensor<3x1x2xf32>
    return %2 : tensor<3x1x2xf32>
}
// CHECK-LABEL: func.func @transpose_move_down_binary_const
// CHECK-NEXT: mhlo.constant
// CHECK-SAME{LITERAL}: dense<[[[1.000000e+00, 3.000000e+00, 5.000000e+00], [2.000000e+00, 4.000000e+00, 6.000000e+00]]]>
// CHECK-NEXT: mhlo.add
// CHECK-NEXT: mhlo.transpose
// CHECK-NEXT: return

func.func @broadcast_move_down_unary(%arg0 : tensor<32xf32>) -> tensor<4x32xf32> {
    %0 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %1 = "mhlo.abs"(%0) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    return %1 : tensor<4x32xf32>
}
// CHECK-LABEL: func.func @broadcast_move_down_unary
// CHECK-NEXT: mhlo.abs
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_move_down_convert(%arg0 : tensor<32xi32>) -> tensor<4x32xf32> {
    %0 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xi32>) -> tensor<4x32xi32>
    %1 = "mhlo.convert"(%0) : (tensor<4x32xi32>) -> tensor<4x32xf32>
    %2 = "mhlo.abs"(%1) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    return %2 : tensor<4x32xf32>
}
// CHECK-LABEL: func.func @broadcast_move_down_convert
// CHECK-SAME: %[[ARG:[a-zA-Z0-9]+]]
// CHECK-NEXT: %[[V0:.*]] = mhlo.convert %[[ARG]] : (tensor<32xi32>) -> tensor<32xf32>
// CHECK-NEXT: %[[V1:.*]] = mhlo.abs %[[V0]] : tensor<32xf32>
// CHECK-NEXT: %[[V2:.*]] = "mhlo.broadcast_in_dim"(%[[V1]])
// CHECK-SAME: (tensor<32xf32>) -> tensor<4x32xf32>
// CHECK-NEXT: return

func.func @broadcast_binary_same(%arg0 : tensor<32xf32>) -> tensor<4x32xf32> {
    %0 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %1 = mhlo.add %0, %0 : tensor<4x32xf32>
    return %1 : tensor<4x32xf32>
}
// CHECK-LABEL: func.func @broadcast_binary_same
// CHECK-NEXT: mhlo.add
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_move_down_binary_with_dtype_alter(%arg0 : tensor<32xf32>, %arg1 : tensor<32xf32>) -> tensor<4x32xi1> {
    %0 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %1 = "mhlo.broadcast_in_dim"(%arg1) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %2 = "mhlo.compare"(%0, %1) {comparison_direction = #mhlo<comparison_direction EQ>} : (tensor<4x32xf32>, tensor<4x32xf32>) -> tensor<4x32xi1>
    return %2 : tensor<4x32xi1>
}
// CHECK-LABEL: func.func @broadcast_move_down_binary_with_dtype_alter
// CHECK-SAME: (%[[ARG0:[a-zA-Z0-9]+]]: tensor<32xf32>, %[[ARG1:[a-zA-Z0-9]+]]: tensor<32xf32>)
// CHECK-NEXT: %[[V0:.*]] = mhlo.compare  EQ, %[[ARG0]], %[[ARG1]]
// CHECK-SAME: (tensor<32xf32>, tensor<32xf32>) -> tensor<32xi1>
// CHECK-NEXT: %[[V1:.*]] = "mhlo.broadcast_in_dim"(%[[V0]])
// CHECK-SAME: (tensor<32xi1>) -> tensor<4x32xi1>
// CHECK-NEXT: return

 func.func @broadcast_move_down_binary_splat_const(%arg0 : tensor<32xf32>) -> tensor<4x32xf32> {
     %0 = mhlo.constant dense<1.000000e+00> : tensor<4x32xf32>
     %1 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
     %2 = mhlo.add %1, %0 : tensor<4x32xf32>
     return %2 : tensor<4x32xf32>
 }
 // CHECK-LABEL: func.func @broadcast_move_down_binary_splat_const
 // CHECK-NEXT: mhlo.constant
 // CHECK-NEXT: mhlo.add
 // CHECK-NEXT: mhlo.broadcast
 // CHECK-NEXT: return

func.func @broadcast_move_down_unary_and_merge(%arg0 : tensor<32xf32>) -> tensor<8x4x32xf32> {
    %0 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %1 = "mhlo.abs"(%0) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    %2 = "mhlo.broadcast_in_dim"(%1) {broadcast_dimensions = dense<[1, 2]> : tensor<2xi64>} : (tensor<4x32xf32>) -> tensor<8x4x32xf32>
    return %2 : tensor<8x4x32xf32>
}
// CHECK-LABEL: func.func @broadcast_move_down_unary_and_merge
// CHECK-NEXT: mhlo.abs
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_move_down_unary_many_and_merge(%arg0 : tensor<32xf32>) -> tensor<8x4x32xf32> {
    %0 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %1 = "mhlo.abs"(%0) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    %2 = "mhlo.sine"(%1) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    %3 = "mhlo.sine"(%2) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    %4 = "mhlo.sine"(%3) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    %5 = "mhlo.broadcast_in_dim"(%4) {broadcast_dimensions = dense<[1, 2]> : tensor<2xi64>} : (tensor<4x32xf32>) -> tensor<8x4x32xf32>
    return %5 : tensor<8x4x32xf32>
}
// CHECK-LABEL: func.func @broadcast_move_down_unary_many_and_merge
// CHECK-NEXT: mhlo.abs
// CHECK-NEXT: mhlo.sine
// CHECK-NEXT: mhlo.sine
// CHECK-NEXT: mhlo.sine
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_parallel_to_binary(%arg0 : tensor<32xf32>, %arg1 : tensor<32xf32>) -> tensor<4x32xf32> {
    %0 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %1 = "mhlo.broadcast_in_dim"(%arg1) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %2 = mhlo.add %0, %1 : tensor<4x32xf32>
    return %2 : tensor<4x32xf32>
}

// CHECK-LABEL: func.func @broadcast_parallel_to_binary
// CHECK-NEXT: mhlo.add
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_parallel_to_binary_with_unary(%arg0 : tensor<32xf32>, %arg1 : tensor<32xf32>) -> tensor<4x32xf32> {
    %0 = "mhlo.broadcast_in_dim"(%arg0) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %1 = "mhlo.abs"(%0) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    %2 = "mhlo.broadcast_in_dim"(%arg1) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<32xf32>) -> tensor<4x32xf32>
    %3 = "mhlo.abs"(%2) : (tensor<4x32xf32>) -> tensor<4x32xf32>
    %4 = mhlo.add %1, %3 : tensor<4x32xf32>
    return %4 : tensor<4x32xf32>
}
// CHECK-LABEL: func.func @broadcast_parallel_to_binary_with_unary
// CHECK-NEXT: mhlo.abs
// CHECK-NEXT: mhlo.abs
// CHECK-NEXT: mhlo.add
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_reshape(%arg0 : tensor<1x64xf16>) -> tensor<1024x64xf16> {
    %0 = "mhlo.broadcast_in_dim" (%arg0) {broadcast_dimensions = dense<[0, 2]> : tensor<2xi64>} : (tensor<1x64xf16>) -> tensor<1x1024x64xf16>
    %1 = "mhlo.reshape"(%0) : (tensor<1x1024x64xf16>) -> tensor<1024x64xf16>
    return %1 : tensor<1024x64xf16>
}

// CHECK-LABEL: func.func @broadcast_reshape
// CHECK-NEXT: mhlo.reshape
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_reshape_dot(%arg0 : tensor<1x64xf16>, %arg1 : tensor<64x176xf16>) -> tensor<1024x176xf16> {
    %0 = "mhlo.broadcast_in_dim" (%arg0) {broadcast_dimensions = dense<[0, 2]> : tensor<2xi64>} : (tensor<1x64xf16>) -> tensor<1x1024x64xf16>
    %1 = "mhlo.reshape"(%0) : (tensor<1x1024x64xf16>) -> tensor<1024x64xf16>
    %2 = "mhlo.dot"(%1, %arg1) : (tensor<1024x64xf16>, tensor<64x176xf16>) -> tensor<1024x176xf16>
    return %2 : tensor<1024x176xf16>
}

// CHECK-LABEL: func.func @broadcast_reshape_dot
// CHECK-NEXT: mhlo.dot
// CHECK-NEXT: mhlo.reshape
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_reshape_dot_with_concat(%arg0 : tensor<1x64xf16>, %arg1: tensor<1024x176xf16>, %arg2 : tensor<64x176xf16>) -> (tensor<1024x240xf16>, tensor<1024x176xf16>) {
    %0 = "mhlo.broadcast_in_dim" (%arg0) {broadcast_dimensions = dense<[0, 2]> : tensor<2xi64>} : (tensor<1x64xf16>) -> tensor<1x1024x64xf16>
    %1 = "mhlo.reshape"(%0) : (tensor<1x1024x64xf16>) -> tensor<1024x64xf16>
    %2 = "mhlo.concatenate"(%arg1, %1) {dimension = 1 : i64} : (tensor<1024x176xf16>, tensor<1024x64xf16>) -> tensor<1024x240xf16>
    %3 = "mhlo.dot"(%1, %arg2) : (tensor<1024x64xf16>, tensor<64x176xf16>) -> tensor<1024x176xf16>
    return %2, %3 : tensor<1024x240xf16>, tensor<1024x176xf16> 
}

// CHECK-LABEL: func.func @broadcast_reshape_dot_with_concat
// CHECK-NEXT: mhlo.reshape
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: mhlo.concatenate
// CHECK-NEXT: mhlo.dot
// CHECK-NEXT: mhlo.reshape
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @broadcast_reshape_dot_with_concat_and_add(%arg0 : tensor<1x64xf16>, %arg1: tensor<1024x176xf16>, %arg2 : tensor<64x176xf16>, %arg3 : tensor<176xf16>) -> (tensor<1024x240xf16>, tensor<1024x176xf16>) {
    %0 = "mhlo.broadcast_in_dim" (%arg0) {broadcast_dimensions = dense<[0, 2]> : tensor<2xi64>} : (tensor<1x64xf16>) -> tensor<1x1024x64xf16>
    %1 = "mhlo.reshape"(%0) : (tensor<1x1024x64xf16>) -> tensor<1024x64xf16>
    %2 = "mhlo.concatenate"(%arg1, %1) {dimension = 1 : i64} : (tensor<1024x176xf16>, tensor<1024x64xf16>) -> tensor<1024x240xf16>
    %3 = "mhlo.dot"(%1, %arg2) : (tensor<1024x64xf16>, tensor<64x176xf16>) -> tensor<1024x176xf16>
    %4 = "mhlo.broadcast_in_dim" (%arg3) {broadcast_dimensions = dense<1> : tensor<1xi64>} : (tensor<176xf16>) -> tensor<1024x176xf16>
    %5 = mhlo.add %3, %4 : tensor<1024x176xf16>
    return %2, %5 : tensor<1024x240xf16>, tensor<1024x176xf16> 
}

// CHECK-LABEL: func.func @broadcast_reshape_dot_with_concat
// CHECK-NEXT: mhlo.reshape
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: mhlo.concatenate
// CHECK-NEXT: mhlo.dot
// CHECK-NEXT: mhlo.reshape
// CHECK-NEXT: mhlo.add
// CHECK-NEXT: mhlo.reshape
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: return

func.func @slice_move_down_unary(%arg0 : tensor<1x64xf16>, %arg1: tensor<1x64xf16>) -> (tensor<1x1xf16>, tensor<1x1xf16>, tensor<1x1xf16>) {
    %0 = "mhlo.add" (%arg0, %arg1) : (tensor<1x64xf16>, tensor<1x64xf16>) -> tensor<1x64xf16>
    %1 = "mhlo.slice"(%0) { limit_indices = dense<[1, 2]> : tensor<2xi64>, start_indices = dense<[0, 1]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> } : (tensor<1x64xf16>) -> tensor<1x1xf16>
    %2 = "mhlo.slice"(%0) { limit_indices = dense<[1, 3]> : tensor<2xi64>, start_indices = dense<[0, 2]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> } : (tensor<1x64xf16>) -> tensor<1x1xf16>
    %3 = "mhlo.slice"(%0) { limit_indices = dense<[1, 4]> : tensor<2xi64>, start_indices = dense<[0, 3]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> } : (tensor<1x64xf16>) -> tensor<1x1xf16>
    %4 = "mhlo.negate"(%1) : (tensor<1x1xf16>) -> tensor<1x1xf16>
    %5 = "mhlo.negate"(%2) : (tensor<1x1xf16>) -> tensor<1x1xf16>
    %6 = "mhlo.negate"(%3) : (tensor<1x1xf16>) -> tensor<1x1xf16>
    %7 = "mhlo.exponential"(%4) : (tensor<1x1xf16>) -> tensor<1x1xf16>
    %8 = "mhlo.exponential"(%5) : (tensor<1x1xf16>) -> tensor<1x1xf16>
    %9 = "mhlo.exponential"(%6) : (tensor<1x1xf16>) -> tensor<1x1xf16>
    return %7, %8, %9 : tensor<1x1xf16>, tensor<1x1xf16>, tensor<1x1xf16>
}

// CHECK-LABEL: func.func @slice_move_down_unary
// CHECK-NEXT: mhlo.add
// CHECK-NEXT: mhlo.negate
// CHECK-NEXT: mhlo.exponential
// CHECK-NEXT: mhlo.slice
// CHECK-NEXT: mhlo.slice
// CHECK-NEXT: mhlo.slice
// CHECK-NEXT: return

func.func @slice_move_down_convert(%arg0 : tensor<1x64xf32>) -> (tensor<1x1xi32>, tensor<1x1xi32>) {
    %0 = "mhlo.slice"(%arg0) { limit_indices = dense<[1, 2]> : tensor<2xi64>, start_indices = dense<[0, 1]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> } : (tensor<1x64xf32>) -> tensor<1x1xf32>
    %1 = "mhlo.slice"(%arg0) { limit_indices = dense<[1, 3]> : tensor<2xi64>, start_indices = dense<[0, 2]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> } : (tensor<1x64xf32>) -> tensor<1x1xf32>
    %2 = "mhlo.convert"(%0) : (tensor<1x1xf32>) -> tensor<1x1xi32>
    %3 = "mhlo.convert"(%1) : (tensor<1x1xf32>) -> tensor<1x1xi32>
    return %2, %3 : tensor<1x1xi32>, tensor<1x1xi32>
}

// CHECK-LABEL: func.func @slice_move_down_convert
// CHECK-SAME: %[[ARG:[a-zA-Z0-9]+]]
// CHECK-NEXT: %[[V0:.*]] = mhlo.convert %[[ARG]] : (tensor<1x64xf32>) -> tensor<1x64xi32>
// CHECK-NEXT: %[[V1:.*]] = "mhlo.slice"(%[[V0]])
// CHECK-SAME: (tensor<1x64xi32>) -> tensor<1x1xi32>
// CHECK-NEXT: %[[V2:.*]] = "mhlo.slice"(%[[V0]])
// CHECK-SAME: (tensor<1x64xi32>) -> tensor<1x1xi32>
// CHECK-NEXT: return %[[V2]], %[[V1]]

func.func @slice_move_down_binary(%arg0 : tensor<1x64xf16>, %arg1: tensor<1x64xf16>, %arg2: tensor<1x1xf16>) -> (tensor<1x1xf16>, tensor<1x1xf16>, tensor<1x1xf16>) {
    %0 = "mhlo.add" (%arg0, %arg1) : (tensor<1x64xf16>, tensor<1x64xf16>) -> tensor<1x64xf16>
    %1 = "mhlo.slice"(%0) { limit_indices = dense<[1, 2]> : tensor<2xi64>, start_indices = dense<[0, 1]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> } : (tensor<1x64xf16>) -> tensor<1x1xf16>
    %2 = "mhlo.slice"(%0) { limit_indices = dense<[1, 3]> : tensor<2xi64>, start_indices = dense<[0, 2]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> } : (tensor<1x64xf16>) -> tensor<1x1xf16>
    %3 = "mhlo.slice"(%0) { limit_indices = dense<[1, 4]> : tensor<2xi64>, start_indices = dense<[0, 3]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64> } : (tensor<1x64xf16>) -> tensor<1x1xf16>
    %4 = "mhlo.add"(%1, %arg2) : (tensor<1x1xf16>, tensor<1x1xf16>) -> tensor<1x1xf16>
    %5 = "mhlo.add"(%2, %arg2) : (tensor<1x1xf16>, tensor<1x1xf16>) -> tensor<1x1xf16>
    %6 = "mhlo.add"(%3, %arg2) : (tensor<1x1xf16>, tensor<1x1xf16>) -> tensor<1x1xf16>
    return %4, %5, %6 : tensor<1x1xf16>, tensor<1x1xf16>, tensor<1x1xf16>
}

// CHECK-LABEL: func.func @slice_move_down_binary
// CHECK-NEXT: mhlo.add
// CHECK-NEXT: mhlo.broadcast_in_dim
// CHECK-NEXT: mhlo.add
// CHECK-NEXT: mhlo.slice
// CHECK-NEXT: mhlo.slice
// CHECK-NEXT: mhlo.slice
// CHECK-NEXT: return
