//! `account`

use libra_json_rpc_client::{AccountAddress, views::AccountView};
use crate::{cache::DB_CACHE, client::pick_client, node_health::NodeHealth, prelude::app_config};
use serde::{Serialize, Deserialize};

const ACCOUNT_INFO_DB_KEY: &str = "account_info";

#[derive(Clone, Debug, Deserialize, Serialize)]
/// information on the owner account of this node.
pub struct AccountInfo {
  /// account address of this node
  address: AccountAddress,
  /// balance of this node
  balance: u64,
  /// if is jailed
  is_in_validator_set: bool,
}

impl AccountInfo {
  /// create AccountCli
  pub fn new() -> Self{
    let cfg = app_config();
    AccountInfo {
      address: cfg.profile.account,
      balance: 0,
      is_in_validator_set: false
    }
  }

  /// fetch new account info
  pub fn refresh(&mut self) -> &AccountInfo {
    let av = get_account_view(self.address);
    self.balance = get_balance(av);

    let node = NodeHealth::new();
    self.is_in_validator_set = node.is_in_validator_set();
    let as_ser = serde_json::to_vec(self).unwrap();
    DB_CACHE.put(ACCOUNT_INFO_DB_KEY.as_bytes(), as_ser).unwrap();
    self
  }

  /// get chain info from cache
  pub fn read_account_info_cache() -> AccountInfo {
    let account_state = DB_CACHE.get(ACCOUNT_INFO_DB_KEY.as_bytes()).unwrap().expect("could not reach account_info cache");
    let c: AccountInfo = serde_json::de::from_slice(&account_state.as_slice()).unwrap();
    c
  }


}

/// Get the account view struct
pub fn get_account_view(account: AccountAddress) -> AccountView {
    let (account_view, _) = pick_client()
      .get_account(account, true)
      .expect(&format!("could not get account at address {:?}", account));
    account_view.expect(&format!("could not get account at address {:?}", account))
}

/// get balance from AccountView
pub fn get_balance(account_view: AccountView) -> u64 {
    for av in account_view.balances.iter() {
      if av.currency == "GAS" {
        return av.amount;//.to_formatted_string(&Locale::en)
      }
    }
    0
}