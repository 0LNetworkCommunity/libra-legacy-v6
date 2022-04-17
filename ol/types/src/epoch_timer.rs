//! autopay view for web monitor

use diem_types::{
    access_path::AccessPath,
    account_config::constants:: CORE_CODE_ADDRESS,
};
use anyhow::Result;
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{ResourceKey, StructTag},
    move_resource::{MoveResource, MoveStructType},
};
use serde::{Deserialize, Serialize};
use move_core_types::account_address::AccountAddress;
use num_format::{Locale, ToFormattedString};

/// Struct that represents a AutoPay resource
#[derive(Debug, Serialize, Deserialize)]
pub struct EpochTimerResource {
    ///
    epoch: u64,
    height_start: u64,
    seconds_start: u64
}

impl MoveStructType for EpochTimerResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("Epoch");
    const STRUCT_NAME: &'static IdentStr = ident_str!("Timer");
}
impl MoveResource for EpochTimerResource {}

impl EpochTimerResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: EpochTimerResource::module_identifier(),
            name: EpochTimerResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(
            account,
            EpochTimerResource::struct_tag(),
        );
        AccessPath::resource_access_path(resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(EpochTimerResource::struct_tag())
    }

    /// 
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        bcs::from_bytes(bytes).map_err(Into::into)
    }
}
