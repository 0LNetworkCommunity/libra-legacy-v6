// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::{
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

/// Struct that represents a MinerStateHistory resource
#[derive(Debug, Serialize, Deserialize)]
pub struct MinerStateResource {
    pub previous_proof_hash: Vec<u8>,
    pub verified_tower_height: u64,
    pub latest_epoch_mining: u64,
    pub count_proofs_in_epoch: u64,
    pub epochs_validating_and_mining: u64,
    pub contiguous_epochs_validating_and_mining: u64,

}

impl MoveResource for MinerStateResource {
    const MODULE_NAME: &'static str = "MinerState";
    const STRUCT_NAME: &'static str = "MinerProofHistory";
}

impl MinerStateResource {

    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: MinerStateResource::module_identifier(),
            name: MinerStateResource::struct_identifier(),
            type_params: vec![],
        }
    }

    pub fn resource_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(
            account,
            MinerStateResource::struct_tag(),
        );
        dbg!(&resource_key);
        AccessPath::resource_access_path(&resource_key)
    }

    pub fn access_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&MinerStateResource::struct_tag())
    }

    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}


/// Struct that represents a MinerStateHistory resource
#[derive(Debug, Serialize, Deserialize)]
pub struct ValConfigResource {
    pub config: ValKeys,
    pub operator_account: Vec<u8>,
}

impl MoveResource for ValConfigResource {
    const MODULE_NAME: &'static str = "ValidatorConfig";
    const STRUCT_NAME: &'static str = "T";
}

impl ValConfigResource {
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: ValConfigResource::module_identifier(),
            name: ValConfigResource::struct_identifier(),
            type_params: vec![],
        }
    }

    pub fn resource_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(
            account,
            ValConfigResource::struct_tag(),
        );
        dbg!(&resource_key);
        AccessPath::resource_access_path(&resource_key)
    }

    pub fn access_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&ValConfigResource::struct_tag())
    }

    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}

#[derive(Debug, Serialize, Deserialize)]

pub struct ValKeys {
    pub consensus_pubkey: Vec<u8>,
    pub validator_network_identity_pubkey: Vec<u8>,
    pub validator_network_address: Vec<u8>,
    pub full_node_network_identity_pubkey: Vec<u8>,
    pub full_node_network_address: Vec<u8>,
}
impl MoveResource for ValKeys {
    const MODULE_NAME: &'static str = "Config";
    const STRUCT_NAME: &'static str = "T";
}