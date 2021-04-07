//! `account`

use libra_json_rpc_client::AccountAddress;

use crate::prelude::app_config;

pub struct AccountCli {
  address: AccountAddress,
  balance: u64,
  jailed: bool,
}

impl AccountCli {
  pub fn new() -> Self{
    let cfg = app_config();
    AccountCli {
      address: cfg.profile.account,
      balance: 0,
      jailed: true
    }
  }
}

