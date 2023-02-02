//! Using the e2e test helpers we create a MoveVm session from fake data to be able to apply migrations
//! from Move system contracts. i.e. we don't craft the writesets
//! manually in rust, instead we execute functions in a Move session.

#[cfg(test)]
use diem_types::account_config;
use diem_types::write_set::WriteSetMut;
use language_e2e_tests::executor::FakeExecutor;
use move_core_types::value::{MoveValue, serialize_values};

#[test]
fn sanity_Check() {
    let mut executor = FakeExecutor::from_fresh_genesis();    
    let output = executor.try_exec(
        "Debug",
        "print_stack_trace",
        vec![],
        serialize_values(&vec![]),
    );


    assert_eq!(output.unwrap_err().move_abort_code(), None);
}


#[test]
fn test_executor_migration() {
    let ws = WriteSetMut::new(vec![]).freeze().unwrap();

    let mut executor = FakeExecutor::from_genesis(&ws);
    
    let output = executor.try_exec(
        "Debug",
        "print_stack_trace",
        vec![],
        serialize_values(&vec![]),
    );


    assert_eq!(output.unwrap_err().move_abort_code(), None);
}