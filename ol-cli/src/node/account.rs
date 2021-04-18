//! `account`


use libra_json_rpc_client::{AccountAddress, views::AccountView};
use crate::{cache::DB_CACHE, node::node::Node};
use serde::{Serialize, Deserialize};
use libra_types::{account_state::AccountState, transaction::Version};
use resource_viewer::{AnnotatedAccountStateBlob, MoveValueAnnotator, NullStateView};
use anyhow::{Error, Result};
use std::convert::TryFrom;

const ACCOUNT_INFO_DB_KEY: &str = "account_info";

#[derive(Clone, Debug, Deserialize, Serialize)]
/// information on the owner account of this node.
pub struct OwnerAccountView {
  /// account address of this node
  address: AccountAddress,
  /// balance of this node
  balance: u64,
  /// if is jailed
  is_in_validator_set: bool,
}

impl OwnerAccountView {
  /// create AccountCli
  pub fn new(address: AccountAddress) -> Self{
    OwnerAccountView {
      address,
      balance: 0,
      is_in_validator_set: false
    }
  }
}

impl Node {
  /// fetch new account info
  pub fn refresh_account_info(&mut self) -> &OwnerAccountView {
    let av = self.get_account_view();
    self.account_info.balance = get_balance(av);
    self.account_info.is_in_validator_set = self.is_in_validator_set();
    
    let ser = serde_json::to_vec(&self.account_info).unwrap();
    DB_CACHE.put(ACCOUNT_INFO_DB_KEY.as_bytes(), ser).expect("could not reach account_info cache");

    &self.account_info
  }

  /// get chain info from cache
  pub fn read_account_info_cache() -> OwnerAccountView {
    let account_state = DB_CACHE.get(ACCOUNT_INFO_DB_KEY.as_bytes()).unwrap().expect("could not reach account_info cache");
    let c: OwnerAccountView = serde_json::de::from_slice(&account_state.as_slice()).unwrap();
    c
  } 

/// Get the account view struct
pub fn get_account_view(&mut self) -> AccountView {
    let account = self.conf.profile.account;
    let (account_view, _) = self.client
      .get_account(account, true)
      .expect(&format!("could not get account at address {:?}", account));
    account_view.expect(&format!("could not get account at address {:?}", account))
}

/// Return a full Move-annotated account resource struct
pub fn get_annotate_account_blob(&mut self, account: AccountAddress) -> Result<(Option<AnnotatedAccountStateBlob>, Version)> {
    let (blob, ver) = self.client.get_account_state_blob(account)?;
    if let Some(account_blob) = blob {
        let state_view = NullStateView::default();
        let annotator = MoveValueAnnotator::new(&state_view);
        let annotate_blob =
            annotator.view_account_state(&AccountState::try_from(&account_blob)?)?;
        Ok((Some(annotate_blob), ver))
    } else {
        Ok((None, ver))
    }
}
  /// get any account state with client
  pub fn get_account_state(
    &mut self,
    address: AccountAddress,
  ) -> Result<AccountState, Error> {
    let (blob, _ver) = self.client.get_account_state_blob(address)?;
    if let Some(account_blob) = blob {
      Ok(AccountState::try_from(&account_blob).unwrap())
    } else {
      Err(Error::msg("connection to client"))
    }
  }

}

/// get balance from AccountView
pub fn get_balance(account_view: AccountView) -> u64 {
    for av in account_view.balances.iter() {
      if av.currency == "GAS" {
        return av.amount / 1_000_000;// with scaling factor for display
      }
    }
    0
}




