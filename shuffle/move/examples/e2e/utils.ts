// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

export * as TxnBuilder from "../main/txn_builders/mod.ts";

export function deployMessageModule() {
  return true;
}

export function setMessage(_address: any, _message: any) {
  return true;
}