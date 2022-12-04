//! validator config view for web monitor

use anyhow::Result;
use diem_types::{access_path::AccessPath, account_config::constants::CORE_CODE_ADDRESS};
use move_core_types::account_address::AccountAddress;
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{ResourceKey, StructTag},
    move_resource::{MoveResource, MoveStructType},
};
use serde::{Deserialize, Serialize};

//// TODO THIS IS DUPLICATED WITH types/src/validator_config.rs
/// Please rename.

/// Struct that represents a Validator Config resource
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ValidatorConfigResource {
    ///
    pub config: Option<ConfigResource>,
    ///
    pub operator_account: Option<AccountAddress>,
    ///
    pub human_name: Vec<u8>,
}

/// Struct that represents a Config resource
#[derive(Debug, Serialize, Clone, Deserialize)]
pub struct ConfigResource {
    ///
    pub consensus_pubkey: Vec<u8>,
    ///
    pub validator_network_addresses: Vec<u8>,
    ///
    pub fullnode_network_addresses: Vec<u8>,
}

impl MoveStructType for ValidatorConfigResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("ValidatorConfig");
    const STRUCT_NAME: &'static IdentStr = ident_str!("ValidatorConfig");
}
impl MoveResource for ValidatorConfigResource {}

impl ValidatorConfigResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: ValidatorConfigResource::module_identifier(),
            name: ValidatorConfigResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(account, ValidatorConfigResource::struct_tag());
        AccessPath::resource_access_path(resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(ValidatorConfigResource::struct_tag())
    }

    ///
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        bcs::from_bytes(bytes).map_err(Into::into)
    }

    ///
    pub fn get_view(&self) -> ValidatorConfigView {
        ValidatorConfigView {
            operator_account: self.operator_account.clone(),
            operator_has_balance: None,
        }
    }
}

/// Struct that represents a view for Validator Config view
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ValidatorConfigView {
    ///
    pub operator_account: Option<AccountAddress>,
    ///
    pub operator_has_balance: Option<bool>,
}
