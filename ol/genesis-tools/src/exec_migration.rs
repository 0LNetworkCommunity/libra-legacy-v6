//! Using the e2e test helpers we create a MoveVm session from fake data to be able to apply migrations
//! from Move system contracts. i.e. we don't craft the writesets
//! manually in rust, instead we execute functions in a Move session.

use crate::recover::LegacyRecovery;
use diem_types::write_set::WriteSet;
use diem_types::write_set::WriteSetMut;
use language_e2e_tests::executor::FakeExecutor;
use move_core_types::{
    language_storage::TypeTag,
    value::{serialize_values, MoveValue},
};

/// creates an executor vm session to create writesets
pub fn start_vm_and_transform(
    genesis_baseline: &WriteSet,
    subset_of_legacy_accounts: Vec<LegacyRecovery>,
    _user_signs: bool, // otherwise the writeset is signed by the diem root
    module_name: &str,
    function_name: &str,
    type_params: Option<Vec<TypeTag>>,
    arg_builder: fn(&LegacyRecovery) -> Vec<MoveValue>, // function pointer to create the transformation from legacy revcovery to the function arguments.
) -> Result<WriteSet, anyhow::Error> {
    let mut executor = FakeExecutor::from_genesis(genesis_baseline);

    let collect_writesets = subset_of_legacy_accounts
        .iter()
        .map(|account| {
            let args = arg_builder(account);
            match executor.try_exec(
                module_name,
                function_name,
                type_params.clone().unwrap_or(vec![]),
                serialize_values(&args),
            ) {
                Ok(o) => o.into_mut().get(),
                Err(e) => {
                    panic!("Error: VM throws error {:?}, for account {:?}", &e, account);
                }
            }
        })
        .reduce(|mut acc, ws| {
            acc.extend(ws);
            acc
        })
        .unwrap_or(vec![]);

    WriteSetMut::new(collect_writesets).freeze()
}
