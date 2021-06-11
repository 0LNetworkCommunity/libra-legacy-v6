//! 'query'
use std::collections::BTreeMap;

use libra_json_rpc_client::{views::TransactionView, AccountAddress};
use move_core_types::{identifier::Identifier, language_storage::{StructTag, TypeTag}};
use num_format::{Locale, ToFormattedString};
use resource_viewer::{AnnotatedAccountStateBlob, AnnotatedMoveStruct, AnnotatedMoveValue};

use super::node::Node;

#[derive(Debug)]
/// What query do we want to return
pub enum QueryType {
    /// Account balance
    Balance {
        /// account to query txs of
        account: AccountAddress,
    },
    /// Epoch and waypoint
    Epoch,
    /// Network block height
    BlockHeight,
    /// All account resources
    Resources {
        /// account to query txs of
        account: AccountAddress,
    },
    /// How far behind the local is from the upstream nodes
    SyncDelay,
    /// Get transaction history
    Txs {
        /// account to query txs of
        account: AccountAddress,
        /// get transactions after this height
        txs_height: Option<u64>,
        /// limit how many txs
        txs_count: Option<u64>,
        /// filter by type
        txs_type: Option<String>,
    },
}

/// Get data from a client, with a query type. Will connect to local only if in sync.
impl Node {
    /// run a query
    pub fn query(&mut self, query_type: QueryType) -> String {
        use QueryType::*;
        match query_type {
            Balance { account } => {
                // TODO: get scaling factor from chain.
                let scaling_factor = 1_000_000;
                match self.client.get_account(account, true) {
                    Ok((Some(account_view), _)) => {
                        for av in account_view.balances.iter() {
                            if av.currency == "GAS" {
                                let amount = av.amount / scaling_factor;
                                return amount.to_formatted_string(&Locale::en);
                            }
                        }
                        return "No GAS found on account".to_owned();
                    }
                    Ok((None, _)) => format!("No account {} found on chain, account", account),
                    Err(e) => format!("Chain query error: {:?}", e),
                }
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
            SyncDelay => match self.check_sync() {
                Ok(sync) => format!(
                    "is synced: {}, local height: {}, upstream delay: {}",
                    sync.is_synced, sync.sync_height, sync.sync_delay
                ),
                Err(e) => e.to_string(),
            },
            Resources { account } => {
                // account
                match self.get_annotate_account_blob(account) {
                    Ok((Some(r), _)) => {
                      
                      format!("{:#?}", r)
                    },
                    Err(e) => format!("Error querying account resource. Message: {:#?}", e),
                    _ => format!("Error, cannot find account state for {:#?}", account),
                }
            }
            Txs {
                account,
                txs_height,
                txs_count,
                txs_type,
            } => {
                let (chain, _) = self.refresh_chain_info();
                let current_height = chain.unwrap().height;
                let query_height = if current_height > 100_000 {
                    current_height - 100_000
                } else {
                    0
                };

                let txs = self
                    .client
                    .get_txn_by_acc_range(
                        account,
                        txs_height.unwrap_or(query_height),
                        txs_count.unwrap_or(100),
                        true,
                    )
                    .unwrap();

                if let Some(t) = txs_type {
                    let filter: Vec<TransactionView> = txs.into_iter()
          .filter(|tv|{
            match &tv.transaction {
                libra_json_rpc_client::views::TransactionDataView::UserTransaction {  script, .. } => {
                  return  script.r#type == t;
                },
                _ => false
            }
          })
          .collect();
                    format!("{:#?}", filter)
                } else {
                    format!("{:#?}", txs)
                }
            }
        }
    }
}

/// test fixtures
pub fn test_fixture_blob() -> AnnotatedAccountStateBlob {
  let mut s = BTreeMap::new();
  let move_struct = test_fixture_struct();
  s.insert(move_struct.type_.clone(), move_struct);
  AnnotatedAccountStateBlob(s)
}

/// stuct fixture
pub fn test_fixture_struct()  -> AnnotatedMoveStruct {
    let module_tag = StructTag {
      address: AccountAddress::random(),
      module: Identifier::new("TestModule").unwrap(),
      name: Identifier::new("TestStructName").unwrap(),
      type_params: vec!(TypeTag::Bool),
    };

    let key = Identifier::new("test_key").unwrap();
    let value = AnnotatedMoveValue::Bool(true);

    AnnotatedMoveStruct {
      is_resource: true,
      type_: module_tag.clone(),
      value: vec!((key, value)),
    }
  }

/// search through the account state blob
pub fn walk_blob(blob: AnnotatedAccountStateBlob, module_name: String) {
    blob.0.values()
    .for_each(|move_struct| {
    dbg!(&move_struct);
    if move_struct.type_.module.clone().into_string() == module_name {
      dbg!("this is the right module");
    } 
    // if move_struct.type_.name.into_string() == "string" {
    //   dbg!("this is the right struct");
    // } 

    // let val: Vec<AnnotatedMoveValue> = move_struct
    //   .value
    //   .into_iter()
    //   .filter_map(|a|{
    //     if a.0.into_string() == "string".to_owned() {
    //       dbg!("this is the right value in a struct");
    //       Some(a.1)
    //     } else {
    //       None
    //     }
    //   })
    //   .collect();
  });
}

#[test]
fn test() {
  let s = test_fixture_blob();
  walk_blob(s, "TestModule".to_owned());
}

