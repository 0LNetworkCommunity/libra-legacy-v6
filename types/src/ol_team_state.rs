//! tower state view for cli

use crate::{
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

/// Struct that represents a CurrencyInfo resource
#[derive(Debug, Serialize, Deserialize)]
pub struct TeamsResource {
    ///
    pub captain: AccountAddress,
    /// user's latest verified_tower_height
    pub team_name: u64, 
    ///
    pub members: Vec<AccountAddress>,
    ///
    pub operator_pct_reward: u64,
    ///
    pub collective_tower_height_this_epoch: u64,

}

impl MoveStructType for TeamsResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("Teams");
    const STRUCT_NAME: &'static IdentStr = ident_str!("Team");
}
impl MoveResource for TeamsResource {}

impl TeamsResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: TeamsResource::module_identifier(),
            name: TeamsResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(
            account,
            TeamsResource::struct_tag(),
        );
        AccessPath::resource_access_path(resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(TeamsResource::struct_tag())
    }

    /// 
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        bcs::from_bytes(bytes).map_err(Into::into)
    }
}
