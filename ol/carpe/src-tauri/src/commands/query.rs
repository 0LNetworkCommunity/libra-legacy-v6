//! query the chain
use diem_types::account_address::AccountAddress;
use ol::node::query::QueryType;
use crate::{carpe_error::CarpeError, configs::get_node_obj};

#[tauri::command]
pub fn query_balance(account: AccountAddress) -> Result<u64, CarpeError>{
  dbg!(&account);
  let mut node = get_node_obj()?;
  let bal = node.query(QueryType::Balance{ account });
  bal.parse::<u64>()
    .map_err(|_| CarpeError::misc("could not parse balance"))
}