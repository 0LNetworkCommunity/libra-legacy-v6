//! fullnode counter for system address

use anyhow::Result;
use diem_types::{access_path::AccessPath, account_config::constants::CORE_CODE_ADDRESS};
use move_core_types::account_address::AccountAddress;
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{ResourceKey, StructTag},
    move_resource::MoveStructType,
};
use serde::{Deserialize, Serialize};

/// Struct that represents a CurrencyInfo resource
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ReceiptsResource {
    ///
    pub destination: Vec<AccountAddress>,
    ///
    pub cumulative: Vec<u64>,
    ///
    pub last_payment_timestamp: Vec<u64>,
    ///
    pub last_payment_value: Vec<u64>,
}

impl MoveStructType for ReceiptsResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("Receipts");
    const STRUCT_NAME: &'static IdentStr = ident_str!("UserReceipts");
}

impl ReceiptsResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: ReceiptsResource::module_identifier(),
            name: ReceiptsResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(account, ReceiptsResource::struct_tag());
        AccessPath::resource_access_path(resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(ReceiptsResource::struct_tag())
    }

    ///
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        bcs::from_bytes(bytes).map_err(Into::into)
    }
}
