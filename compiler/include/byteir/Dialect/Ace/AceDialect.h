//===- AceDialect.h - MLIR Dialect for Mhlo Extension ---------*--- C++ -*-===//
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

#ifndef BYTEIR_DIALECT_ACE_ACEDIALECT_H
#define BYTEIR_DIALECT_ACE_ACEDIALECT_H

#include "mlir/IR/BuiltinTypes.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"

#define GET_TYPEDEF_CLASSES
#include "byteir/Dialect/Ace/AceOpsTypes.h.inc"

#define GET_ATTRDEF_CLASSES
#include "byteir/Dialect/Ace/AceOpsAttributes.h.inc"

#include "byteir/Dialect/Ace/AceOpsDialect.h.inc"

#define GET_OP_CLASSES
#include "byteir/Dialect/Ace/AceOps.h.inc"

#endif // BYTEIR_DIALECT_ACE_ACEDIALECT_H
