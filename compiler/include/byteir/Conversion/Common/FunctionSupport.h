//===- FunctionSupport.h --------------------------------------*--- C++ -*-===//
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

#ifndef BYTEIR_CONVERSION_FUNCTIONSUPPORT_H
#define BYTEIR_CONVERSION_FUNCTIONSUPPORT_H

#include "mlir/Dialect/Func/IR/FuncOps.h"
#include "mlir/IR/BuiltinOps.h"
#include "mlir/IR/Operation.h"
#include "mlir/IR/Value.h"
#include "llvm/ADT/StringRef.h"
#include <functional>

namespace mlir {

//
// (LWC) NOTE This implementation DO NOT support inout,
// meaning directly returning an input as an results
// (LWC) NOTE Also DO NOT support duplicated results.
//
void replicateFuncOpResults(func::FuncOp funcOp);

void replicateFuncOpResults(func::FuncOp funcOp,
                            std::function<void(func::ReturnOp)> retOpHandling);

void relocateFuncOpConstantLike(
    func::FuncOp funcOp, std::function<bool(Operation *)> checkOp,
    std::function<std::tuple<Value, NamedAttrList>(Operation *)> getValue);

} // namespace mlir

#endif // BYTEIR_CONVERSION_FUNCTIONSUPPORT_H