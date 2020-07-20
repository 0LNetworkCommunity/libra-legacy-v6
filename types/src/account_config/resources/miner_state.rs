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

/// Struct that represents a CurrencyInfo resource
#[derive(Debug, Serialize, Deserialize)]
pub struct MinerStateResource {
    verified_proof_history: Vec<Vec<u8>>,
    invalid_proof_history: Vec<Vec<u8>>,
    reported_tower_height: u64,
    verified_tower_height: u64, // user's latest verified_tower_height
    latest_epoch_mining: u64,
    epochs_validating_and_mining: u64,
    contiguous_epochs_validating_and_mining: u64,
}

impl MoveResource for MinerStateResource {
    const MODULE_NAME: &'static str = "MinerState";
    const STRUCT_NAME: &'static str = "MinerState";
}

impl MinerStateResource {
    pub fn reported_tower_height(&self) -> u64 {
        self.reported_tower_height
    }

    pub fn verified_tower_height(&self) -> u64 {
        self.verified_tower_height
    }

    pub fn latest_epoch_mining(&self) -> u64 {
        self.latest_epoch_mining
    }

    pub fn epochs_validating_and_mining(&self) -> u64 {
        self.epochs_validating_and_mining
    }
    pub fn contiguous_epochs_validating_and_mining(&self) -> u64 {
        self.contiguous_epochs_validating_and_mining
    }

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
        AccessPath::resource_access_path(&resource_key)
    }

    pub fn access_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&MinerStateResource::struct_tag())
    }

    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}
