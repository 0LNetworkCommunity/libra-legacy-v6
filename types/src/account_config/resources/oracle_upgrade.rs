// add by Ping

use crate::{
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

/// Struct that represents a Oracles resource
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct OracleResource {
    pub upgrade: UpgradeOracle,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct Vote {
    pub validator: AccountAddress,
    pub data: Vec<u8>,
    pub version_id: u64,
}

#[derive(Debug, Serialize, Deserialize, Clone,PartialEq)]
pub struct VoteCount {
    pub data: Vec<u8>,
    pub validators: Vec<AccountAddress>,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct UpgradeOracle{
    // id of the upgrade oracle
    pub id: u64,                            // 1

    // Info of the current window
    pub validators_voted: Vec<AccountAddress>,  // Each validator can only vote once in the current window
    pub vote_counts: Vec<VoteCount>,     // Stores counts for each suggested payload
    pub votes: Vec<Vote>,                // All the received votes
    pub vote_window: u64,                   // End of the current window, in block height
    pub version_id: u64,                    // Version id of the current window
    pub consensus: VoteCount,
}

impl MoveResource for OracleResource {
    const MODULE_NAME: &'static str = "Oracle";
    const STRUCT_NAME: &'static str = "Oracles";
}

impl OracleResource {

    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: OracleResource::module_identifier(),
            name: OracleResource::struct_identifier(),
            type_params: vec![],
        }
    }

    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&OracleResource::struct_tag())
    }

    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}
