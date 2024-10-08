#ifndef TORCH_FRONTEND_TORCH_TRANSFORMS_PASSES_TD
#define TORCH_FRONTEND_TORCH_TRANSFORMS_PASSES_TD

include "mlir/Pass/PassBase.td"

//===----------------------------------------------------------------------===//
// FuseOpOnTorch
//===----------------------------------------------------------------------===//

def FuseOpOnTorch : Pass<"fuse-op-on-torch", "func::FuncOp"> {
  let summary = "fuse op on torch dialect";
  let constructor = "mlir::createFuseOpOnTorch(/*validCustomCallOps=*/{})";
  let options = [
    ListOption<"validCustomCallOps", "valid-custom-call-ops", "std::string",
               "List of ops to be lowered to byteir custom call">,
  ];
}

//===----------------------------------------------------------------------===//
// DecomposeOnTorch
//===----------------------------------------------------------------------===//

def DecomposeOnTorch : Pass<"decompose-on-torch", "func::FuncOp"> {
    let summary = "decompose op on torch dialect";
    let constructor = "mlir::createDecomposeOnTorch(/*legalOps=*/{})";
    let options = [
      ListOption<"legalOps", "legal-ops", "std::string",
               "List of operation names that should be considered legal",
               "llvm::cl::ZeroOrMore">
    ];
}

#endif // TORCH_FRONTEND_TORCH_TRANSFORMS_PASSES_TD
