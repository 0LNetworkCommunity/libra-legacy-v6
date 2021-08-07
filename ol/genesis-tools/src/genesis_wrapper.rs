//! genesis-wrapper

use crate::recover::RecoverConsensusAccounts;
use anyhow::Error;
use libra_types::account_address::AccountAddress;
use libra_types::transaction::{Transaction, WriteSetPayload};
use vm_genesis::encode_recovery_genesis_changeset;


/// make the recovery genesis transaction, and file
pub fn make_recovery_genesis(genesis_accounts: RecoverConsensusAccounts, set: &[AccountAddress]) -> Result<Transaction, Error> {
  // Get a base change set
  let cs = encode_recovery_genesis_changeset(
    &genesis_accounts.vals, 
    &genesis_accounts.opers, 
    &set, 
    1
  )?;

  // add writesets, for recovering e.g. user accounts, balance, miner state, or application state 

  // merge writesets


  // make the genesis transaction
  let gen_tx = Transaction::GenesisTransaction(WriteSetPayload::Direct(cs));

  // optionally save to file
  Ok(gen_tx)
}