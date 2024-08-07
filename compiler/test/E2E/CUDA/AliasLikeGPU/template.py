Testcase(
    contents=[Content(stages=(Input), content=r"""
func.func @main(%arg0: tensor<512x200xf32>, %arg1: tensor<512x2x100xf32>) -> tensor<128x2x100xf32> {
    %0 = "mhlo.slice"(%arg0) {limit_indices = dense<[128, 200]> : tensor<2xi64>, start_indices = dense<[0, 0]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>} : (tensor<512x200xf32>) -> tensor<128x200xf32>
    %1 = "mhlo.slice"(%arg0) {limit_indices = dense<[138, 200]> : tensor<2xi64>, start_indices = dense<[10, 0]> : tensor<2xi64>, strides = dense<1> : tensor<2xi64>} : (tensor<512x200xf32>) -> tensor<128x200xf32>
    %2 = mhlo.reshape %0 : (tensor<128x200xf32>) -> tensor<128x2x100xf32>
    %3 = mhlo.reshape %1 : (tensor<128x200xf32>) -> tensor<128x2x100xf32>
    %4 = mhlo.add %2, %3 : tensor<128x2x100xf32>
    return %4 : tensor<128x2x100xf32>
}
    """)],
    pipelines=[
        InputPipeline(r"""
// CHECK-LABEL: func.func @main
"""),
        HloOptPipeline(r"""
// CHECK-LABEL: func.func private @Unknown
"""),
        LinalgTensorOptPipeline(r"""
// CHECK-LABEL: func.func private @Unknown
"""),
        ByreTensorOptPipeline(r"""
// CHECK-LABEL: func.func private @Unknown
"""),
        BufferizeOptPipeline(r"""
// CHECK-LABEL: func.func private @Unknown
"""),
        SCFOptPipeline(r"""
// CHECK-LABEL: func.func private @Unknown
"""),
        GPUOptPipeline(r"""
// CHECK-LABEL: gpu.func @Unknown0
"""),
        SetSpaceOptPipeline(r"""
// CHECK-LABEL: gpu.func @Unknown0
"""),
        ByreOptPipeline(r"""
// CHECK-LABEL: gpu.func @Unknown0
"""),
        ByreHostPipeline(r"""
// CHECK-LABEL: func.func @main
"""),
        HostOutputPipeline(r"""
// CHECK-LABEL: func.func @main
"""),
        NVVMCodegenPipeline(r"""
// CHECK-LABEL: llvm.func @Unknown0
"""),
        PTXCodegenPipeline(r"""
// CHECK-LABEL: .visible .entry Unknown0
"""),
    ]
)
