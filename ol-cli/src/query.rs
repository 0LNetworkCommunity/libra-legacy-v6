//! 'query' 
use cli::libra_client::LibraClient;
use libra_json_rpc_client::views::AccountView;
use crate::{
  client,
  account_resource::get_annotate_account_blob,
  metadata::Metadata,
  
};
use libra_types::{account_address::AccountAddress};
use num_format::{Locale, ToFormattedString};

#[derive(Debug)]
/// What query do we want to return
pub enum QueryType {
  /// Account balance
  Balance,
  /// Network block height
  BlockHeight,
  /// All account resources
  Resources,
  /// How far behind the local is from the upstream nodes
  SyncDelay,
}

/// Get data from a client, with a query type. Will connect to local only if in sync.
pub fn get(query_type: QueryType, account: AccountAddress) -> String {
  use QueryType::*;
  match query_type {
    Balance => {
      let account_view = get_account_view(account);
      for av in account_view.balances.iter() {
        if av.currency == "GAS" {
          return av.amount.to_formatted_string(&Locale::en)
        }
      }
      "0".to_string()
    },
    BlockHeight => {
      let (chain, _) = crate::chain_info::fetch_chain_info();
      chain.unwrap().height.to_string()
    },
    SyncDelay => {
      Metadata::compare_from_config().to_string()
    },
    Resources => {
      let resources = get_annotate_account_blob(what_client(), account)
      .unwrap()
      .0
      .unwrap();
      
      format!("{:#?}", resources).to_string()
    },
  }
}


fn get_account_view(account: AccountAddress) -> AccountView {
    let (account_view, _) = what_client()
      .get_account(account, true)
      .expect(&format!("could not get account at address {:?}", account));
    account_view.expect(&format!("could not get account at address {:?}", account))
}

fn what_client() -> LibraClient{
    // check if is in sync
    let is_synced = true;
    let client_tuple = 
      if is_synced { client::default_local_client() }
      else         { client::default_remote_client() };
    client_tuple.0.expect("could not configure a client")
}