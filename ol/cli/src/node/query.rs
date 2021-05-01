//! 'query'
use num_format::{Locale, ToFormattedString};
use super::node::Node;

#[derive(Debug)]
/// What query do we want to return
pub enum QueryType {
  /// Account balance
  Balance,
  /// Epoch and waypoint
  Epoch,
  /// Network block height
  BlockHeight,
  /// All account resources
  Resources,
  /// How far behind the local is from the upstream nodes
  SyncDelay,
}

/// Get data from a client, with a query type. Will connect to local only if in sync.
impl Node {
  /// run a query
  pub fn get(&mut self, query_type: QueryType) -> String {
    use QueryType::*;
    match query_type {
      Balance => {
        match self.get_account_view() {
            Some(account_view) => {
              for av in account_view.balances.iter() {
                if av.currency == "GAS" {
                  return av.amount.to_formatted_string(&Locale::en);
                }
              }
            },
            None => {}
        }
        "0".to_string()
      }
      BlockHeight => {
        let (chain, _) = self.refresh_chain_info();
        chain.unwrap().height.to_string()
      }
      Epoch => {
        let (chain, _) = self.refresh_chain_info();

        format!(
          "{} - WAYPOINT: {}",
          chain.clone().unwrap().epoch.to_string(),
          &chain.unwrap().waypoint.unwrap().to_string()
        )
      }
      SyncDelay => self.is_synced().1.to_string(),
      Resources => {
        let resources = self.get_annotate_account_blob(self.conf.profile.account)
          .unwrap()
          .0
          .unwrap();

        format!("{:#?}", resources).to_string()
      }
    }
  }
}

// fn get_account_view(account: AccountAddress) -> AccountView {
//     let (account_view, _) = pick_client()
//       .get_account(account, true)
//       .expect(&format!("could not get account at address {:?}", account));
//     account_view.expect(&format!("could not get account at address {:?}", account))
// }
