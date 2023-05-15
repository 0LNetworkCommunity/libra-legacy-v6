// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use bytecode_verifier::CodeUnitVerifier;
use move_binary_format::file_format::{self, Bytecode, dummy_procedure_module};
use move_core_types::vm_status::StatusCode;

#[test]
fn invalid_fallthrough_br_true() {
    let module = file_format::dummy_procedure_module(vec![Bytecode::LdFalse, Bytecode::BrTrue(1)]);
    let result = CodeUnitVerifier::verify_module(&module);
    assert_eq!(
        result.unwrap_err().major_status(),
        StatusCode::INVALID_FALL_THROUGH
    );
}

#[test]
fn invalid_fallthrough_br_false() {
    let module = file_format::dummy_procedure_module(vec![Bytecode::LdTrue, Bytecode::BrFalse(1)]);
    let result = CodeUnitVerifier::verify_module(&module);
    assert_eq!(
        result.unwrap_err().major_status(),
        StatusCode::INVALID_FALL_THROUGH
    );
}

// all non-branch instructions should trigger invalid fallthrough; just check one of them
#[test]
fn invalid_fallthrough_non_branch() {
    let module = file_format::dummy_procedure_module(vec![Bytecode::LdTrue, Bytecode::Pop]);
    let result = CodeUnitVerifier::verify_module(&module);
    assert_eq!(
        result.unwrap_err().major_status(),
        StatusCode::INVALID_FALL_THROUGH
    );
}

#[test]
fn valid_fallthrough_branch() {
    let module = file_format::dummy_procedure_module(vec![Bytecode::Branch(0)]);
    let result = CodeUnitVerifier::verify_module(&module);
    assert!(result.is_ok());
}

#[test]
fn valid_fallthrough_ret() {
    let module = file_format::dummy_procedure_module(vec![Bytecode::Ret]);
    let result = CodeUnitVerifier::verify_module(&module);
    assert!(result.is_ok());
}

#[test]
fn valid_fallthrough_abort() {
    let module = file_format::dummy_procedure_module(vec![Bytecode::LdU64(7), Bytecode::Abort]);
    let result = CodeUnitVerifier::verify_module(&module);
    assert!(result.is_ok());
}

//////// 0L ////////
// belt and suspenders tests for max bytecode. Also in move-binary-format
// patch related to successors bug fix https://github.com/move-language/move/pull/1029/commits/1fa4ed20daaef28b47fe2c5a8d8f63b64523e16d
#[test]
fn test_max_number_of_bytecode() {
    let mut nops = vec![];
    for _ in 0..u16::MAX - 1 {
        nops.push(Bytecode::Nop);
    }
    nops.push(Bytecode::Ret);
    let module = dummy_procedure_module(nops);

    let result = CodeUnitVerifier::verify_module(&module);
    assert!(result.is_ok());
}