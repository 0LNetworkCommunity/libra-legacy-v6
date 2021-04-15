//! `account`

use libra_json_rpc_client::AccountAddress;

use crate::prelude::app_config;

/// information on the owner account of this node.
pub struct AccountCli {
  address: AccountAddress,
  balance: u64,
  jailed: bool,
}

impl AccountCli {
  /// create AccountCli
  pub fn new() -> Self{
    let cfg = app_config();
    AccountCli {
      address: cfg.profile.account,
      balance: 0,
      jailed: true
    }
  }
}

