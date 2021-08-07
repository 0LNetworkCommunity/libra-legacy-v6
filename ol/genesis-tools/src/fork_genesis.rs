//! genesis-wrapper

use std::fs::File;
use std::io::Write;
use std::path::PathBuf;

use crate::read_archive::{archive_into_recovery, merge_writeset};
use crate::recover::{LegacyRecovery, RecoverConsensusAccounts, recover_consensus_accounts};
use anyhow::Error;
use futures::executor::block_on;
use libra_types::access_path::AccessPath;
use libra_types::account_address::AccountAddress;
use libra_types::account_config::BalanceResource;
use libra_types::transaction::{ChangeSet, Transaction, WriteSetPayload};
use libra_types::write_set::{WriteOp, WriteSetMut};
use move_core_types::move_resource::MoveResource;
use vm_genesis::encode_recovery_genesis_changeset;


/// Make a recovery genesis blob
pub async fn make_recovery_genesis(
  genesis_blob_path: PathBuf,
  archive_path: PathBuf,
) -> Result<(), Error> {
  // get the legacy data from archive
  let legacy = archive_into_recovery(&archive_path).await?;
  // get consensus accounts
  let genesis_accounts = recover_consensus_accounts(&legacy)?;
  // create baseline genesis

  // TODO: for testing letting all validators be in genesis set.
  let validator_set: Vec<AccountAddress> = genesis_accounts.vals.clone()
      .into_iter()
      .map(|a|{
        return a.val_account
      })
      .collect();

  let cs = get_baseline_genesis_change_set(genesis_accounts, &validator_set)?;
  // append genesis
  let gen_tx = append_genesis(cs, legacy)?;
  // save genesis
  save_genesis(gen_tx, genesis_blob_path)
}
/// Get the minimal viable genesis from consensus accounts.
pub fn get_baseline_genesis_change_set(
    genesis_accounts: RecoverConsensusAccounts,
    validator_set: &[AccountAddress],
) -> Result<ChangeSet, Error> {
    encode_recovery_genesis_changeset(
        &genesis_accounts.vals,
        &genesis_accounts.opers,
        &validator_set,
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
pub fn save_genesis(gen_tx: Transaction, output_path: PathBuf) -> Result<(), Error> {
    let mut file = File::create(output_path)?;
    let bytes = lcs::to_bytes(&gen_tx)?;
    file.write_all(&bytes)?;
    Ok(())
}
