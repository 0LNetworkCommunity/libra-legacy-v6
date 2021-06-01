//! Validators Stats for Web Monitor

use libra_types::{
    access_path::AccessPath,
    account_config::constants:: CORE_CODE_ADDRESS,
};
use anyhow::Result;
use move_core_types::{
    language_storage::StructTag,
    move_resource::MoveResource,
};
use serde::{Deserialize, Serialize};
use move_core_types::account_address::AccountAddress;

/// Stats of propositions and votes from all validators
#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct SetData {
    /// Validators addresses
    pub addr: Vec<AccountAddress>,
    /// Validators proposed count
    pub prop_count: Vec<u64>,
    /// Validators vote count
    pub vote_count: Vec<u64>,
    /// Ledger total votes
    pub total_votes: u64,
    /// Ledger total propositions
    pub total_props: u64,
}

/// Struct that represents a Validators Stats resource
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct ValsStatsResource {
    /// Stats history
    pub history: Vec<SetData>,
    /// Current epoch stats
    pub current: SetData,
}

impl MoveResource for ValsStatsResource {
    const MODULE_NAME: &'static str = "Stats";
    const STRUCT_NAME: &'static str = "ValStats";
}

impl ValsStatsResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: ValsStatsResource::module_identifier(),
            name: ValsStatsResource::struct_identifier(),
            type_params: vec![],
        }
    }

    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&ValsStatsResource::struct_tag())
    }

    ///
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}
