//! community wallet resource

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

/// Struct that represents a CommunityWallet resource
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommunityWalletsResource {
    /// List
    pub list: Vec<AccountAddress>,

}

impl MoveResource for CommunityWalletsResource {
    const MODULE_NAME: &'static str = "Wallet";
    const STRUCT_NAME: &'static str = "CommunityWallets";
}

impl CommunityWalletsResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: CommunityWalletsResource::module_identifier(),
            name: CommunityWalletsResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(
            account,
            CommunityWalletsResource::struct_tag(),
        );
        AccessPath::resource_access_path(&resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&CommunityWalletsResource::struct_tag())
    }

    /// 
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}



/// Struct that represents a SlowWallet resource
#[derive(Debug, Serialize, Deserialize)]
pub struct SlowWalletResource {
    /// List
    pub is_slow: bool,

}

impl MoveResource for SlowWalletResource {
    const MODULE_NAME: &'static str = "Wallet";
    const STRUCT_NAME: &'static str = "SlowWallet";
}

impl SlowWalletResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: CommunityWalletsResource::module_identifier(),
            name: CommunityWalletsResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(
            account,
            SlowWalletResource::struct_tag(),
        );
        AccessPath::resource_access_path(&resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(&SlowWalletResource::struct_tag())
    }

    /// 
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}
