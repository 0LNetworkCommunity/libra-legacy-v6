/// 0L Resource

use crate::{
    access_path::AccessPath,
    account_config::constants::CORE_CODE_ADDRESS,
};

use anyhow::Result;
use move_core_types::{
    language_storage::StructTag,
    move_resource::MoveResource,
};
use serde::{Deserialize, Serialize};
use move_core_types::account_address::AccountAddress;

pub struct ValidatorStats {
    pub vote_count: u64,
    pub prop_count: u64,
}

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
pub struct ValidatorsStatsResource {
    /// Stats history
    pub history: Vec<SetData>,
    /// Current epoch stats
    pub current: SetData,
}

impl MoveResource for ValidatorsStatsResource {
    const MODULE_NAME: &'static str = "Stats";
    const STRUCT_NAME: &'static str = "ValStats";
}

impl ValidatorsStatsResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: ValidatorsStatsResource::module_identifier(),
            name: ValidatorsStatsResource::struct_identifier(),
            type_params: vec![],
        }
    }

    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&ValidatorsStatsResource::struct_tag())
    }

    ///
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        println!("ValidatorsStatsResource >> try_from_bytes");
        lcs::from_bytes(bytes).map_err(Into::into)
    }

    pub fn get_validator_current_stats(&self, validator_address: AccountAddress) -> ValidatorStats {
        let validator_index = self.get_validator_index(validator_address);
        ValidatorStats {
            vote_count: self.current.vote_count.get(validator_index).unwrap().to_owned(),
            prop_count: self.current.prop_count.get(validator_index).unwrap().to_owned(),
        }
    }
    
    pub fn get_validator_index(&self, validator_address: AccountAddress) -> usize {
        self.current.addr.iter().position(|&each| each == validator_address).unwrap()
    }
}
