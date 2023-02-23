//! Test validator set

use vm_genesis::{TestValidator, Validator};


pub fn get_test_valset(num: usize) -> Vec<Validator> {
  TestValidator::new_test_set(Some(num))
  .into_iter()
  .map(|v| {

    v.data
  })
  .collect()

}