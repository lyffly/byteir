func.func @minimum_i64(%arg0 : tensor<256x1xi64>, %arg1 : tensor<256x1xi64>) -> tensor<256x1xi64> {
  %0 = "stablehlo.minimum"(%arg0, %arg1) : (tensor<256x1xi64>, tensor<256x1xi64>) -> tensor<256x1xi64>
  func.return %0 : tensor<256x1xi64>
}
