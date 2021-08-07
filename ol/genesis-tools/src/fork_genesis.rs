//! genesis-wrapper

use std::path::PathBuf;

use crate::read_archive::merge_writeset;
use crate::recover::{LegacyRecovery, RecoverConsensusAccounts};
use anyhow::Error;
use libra_types::access_path::AccessPath;
use libra_types::account_address::AccountAddress;
use libra_types::account_config::BalanceResource;
use libra_types::transaction::{ChangeSet, Transaction, WriteSetPayload};
use libra_types::write_set::{WriteOp, WriteSetMut};
use move_core_types::move_resource::MoveResource;
use vm_genesis::encode_recovery_genesis_changeset;

/// Get the minimal viable genesis from consensus accounts.
pub fn get_baseline_genesis_change_set(
    genesis_accounts: RecoverConsensusAccounts,
    set: &[AccountAddress],
) -> Result<ChangeSet, Error> {
    encode_recovery_genesis_changeset(
        &genesis_accounts.vals,
        &genesis_accounts.opers,
        &set,
        1, // mainnet
    )
}

/// make the recovery genesis transaction, and file
pub fn append_genesis(
    gen_cs: ChangeSet,
    legacy_vec: Vec<LegacyRecovery>,
) -> Result<Transaction, Error> {
    // merge writesets
    let mut all_writesets = gen_cs.write_set().to_owned().into_mut();
    for l in legacy_vec {
      let ws = migrate_account(l)?;
      all_writesets = merge_writeset(all_writesets, ws)?;
    }
    
    let all_changes = ChangeSet::new(all_writesets.freeze().unwrap(), gen_cs.events().to_owned());
    Ok(Transaction::GenesisTransaction(WriteSetPayload::Direct(
        all_changes,
    )))
}
/// make the recovery genesis transaction, and file
pub fn migrate_account(legacy: LegacyRecovery) -> Result<WriteSetMut, Error> {
    let mut write_set_mut = WriteSetMut::new(vec![]);

    // add writesets, for recovering e.g. user accounts, balance, miner state, or application state

    // TODO: Restore Balance and Total Supply
    // legacy.balance
    // TODO: Change legacy names
    // NOTE: this is only needed from Libra -> Diem renames
    let value = legacy.balance.unwrap().coin();
    let new = BalanceResource::new(value);
    write_set_mut.push((
        AccessPath::new(legacy.account, BalanceResource::resource_path()),
        WriteOp::Value(lcs::to_bytes(&new).unwrap()),
    ));
    // TODO: Restore Mining

    // TODO: Restore FullnodeState

    // TODO: Restore WalletType

    // make the genesis transaction
    Ok(write_set_mut)
}

/// save the genesis blob
pub fn save_genesis(gen_tx: Transaction, output_path: PathBuf) {}
