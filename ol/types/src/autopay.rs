//! miner state view for cli

use libra_types::{
    access_path::AccessPath,
    account_config::constants:: CORE_CODE_ADDRESS,
};
use anyhow::Result;
use move_core_types::{
    language_storage::{ResourceKey, StructTag},
    move_resource::MoveResource,
};
use serde::{Deserialize, Serialize};
use move_core_types::account_address::AccountAddress;

/// Struct that represents a AutoPay resource
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AutoPayResource {
    ///
    pub payment: Vec<Payment>,
}

/// Struct that represents a view for AutoPay resource
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AutoPayView {
    /// 
    pub payments: Vec<Payment>,
}

/// Autopay instruction
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Payment {
    ///
    pub uid: u64,
    ///
    pub in_type: u8,
    ///
    pub payee: AccountAddress,
    ///
    pub end_epoch: u64,
    ///
    pub prev_bal: u64,
    ///
    pub amt: u64,
}

impl MoveResource for AutoPayResource {
    const MODULE_NAME: &'static str = "AutoPay2";
    const STRUCT_NAME: &'static str = "Data";
}

impl AutoPayResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: AutoPayResource::module_identifier(),
            name: AutoPayResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(
            account,
            AutoPayResource::struct_tag(),
        );
        AccessPath::resource_access_path(&resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&AutoPayResource::struct_tag())
    }

    /// 
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }

    ///
    pub fn get_view(&self) -> AutoPayView {
        AutoPayView { payments: self.payment.clone() }
    }
}

