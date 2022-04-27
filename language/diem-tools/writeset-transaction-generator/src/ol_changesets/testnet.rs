use std::path::PathBuf;

use anyhow::Result;

use diem_types::{
    account_config::diem_root_address,
    transaction::{ChangeSet, TransactionArgument},
};

use super::wrapper::{self, FunctionWrapper};

pub fn ol_testnet_changeset(path: PathBuf) -> Result<ChangeSet> {
    let txn_args = vec![TransactionArgument::Address(diem_root_address())];

    let fnwrap = FunctionWrapper {
        module_name: "Testnet".to_string(),
        function_name: "initialize".to_string(),
        txn_args,
    };

    wrapper::function_changeset_from_db(path, vec![fnwrap])
}

pub fn ol_staging_net_changeset(path: PathBuf) -> Result<ChangeSet> {
    let txn_args = vec![TransactionArgument::Address(diem_root_address())];

    let fnwrap = FunctionWrapper {
        module_name: "StagingNet".to_string(),
        function_name: "initialize".to_string(),
        txn_args,
    };

    wrapper::function_changeset_from_db(path, vec![fnwrap])
}
