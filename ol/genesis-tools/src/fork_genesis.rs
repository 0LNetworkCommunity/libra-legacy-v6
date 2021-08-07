//! genesis-wrapper

use std::path::PathBuf;

use crate::recover::{GenesisRecovery, RecoverConsensusAccounts};
use anyhow::Error;
use libra_types::account_address::AccountAddress;
use libra_types::transaction::{ChangeSet, Transaction, WriteSetPayload};
use vm_genesis::encode_recovery_genesis_changeset;


pub fn get_baseline_genesis_change_set(genesis_accounts: RecoverConsensusAccounts, set: &[AccountAddress]) -> Result<ChangeSet, Error>  {
  encode_recovery_genesis_changeset(
    &genesis_accounts.vals, 
    &genesis_accounts.opers, 
    &set, 
    1 // mainnet
  )
}

/// make the recovery genesis transaction, and file
pub fn append_genesis(gen_cs: ChangeSet, recover: GenesisRecovery, output_path: Option<PathBuf>) -> Result<Transaction, Error> {
  // add writesets, for recovering e.g. user accounts, balance, miner state, or application state 

  // merge writesets


  // make the genesis transaction
  Ok(Transaction::GenesisTransaction(WriteSetPayload::Direct(gen_cs)))
}

pub fn save_genesis(gen_tx: Transaction, output_path: PathBuf) {

}
