func.func @convert_f64_f32(%arg0 : tensor<1x256x1024xf64>) -> tensor<1x256x1024xf32> { 
  %0 = stablehlo.convert %arg0 : (tensor<1x256x1024xf64>) -> tensor<1x256x1024xf32>
  func.return %0 : tensor<1x256x1024xf32>
}