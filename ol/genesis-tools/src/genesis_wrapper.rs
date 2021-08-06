//! genesis-wrapper

use std::path::PathBuf;
use vm_genesis::encode_recovery_genesis_transaction;
use crate::recover::GenesisRecovery;

pub fn genesis_from_recovery_file(recover:Vec<GenesisRecovery>, path_to_genesis: PathBuf, path_to_recovery: PathBuf){
  // read file
  // let genesis = encode_recovery_genesis_transaction(recover, )?;

  // create transaction
  // save transaction
}