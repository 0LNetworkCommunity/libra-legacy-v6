//! community wallet resource

use anyhow::Result;
use diem_types::{access_path::AccessPath, account_config::constants::CORE_CODE_ADDRESS};
use move_core_types::account_address::AccountAddress;
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{ResourceKey, StructTag},
    move_resource::MoveStructType,
};
use serde::{Deserialize, Serialize};

// NOTE: these are legacy structs for v5

/// Struct that represents a CommunityWallet resource
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct CommunityWalletsResourceLegacy {
    /// List
    pub list: Vec<AccountAddress>,
}

impl MoveStructType for CommunityWalletsResourceLegacy {
    const MODULE_NAME: &'static IdentStr = ident_str!("Wallet");
    const STRUCT_NAME: &'static IdentStr = ident_str!("CommunityWallets");
}

impl CommunityWalletsResourceLegacy {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: CommunityWalletsResourceLegacy::module_identifier(),
            name: CommunityWalletsResourceLegacy::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(account, CommunityWalletsResourceLegacy::struct_tag());
        AccessPath::resource_access_path(resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(CommunityWalletsResourceLegacy::struct_tag())
    }

    ///
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        bcs::from_bytes(bytes).map_err(Into::into)
    }
}

/// Struct that represents a SlowWallet resource
#[derive(Debug, Serialize, Deserialize)]
pub struct SlowWalletResource {
    ///
    pub unlocked: u64,
    ///
    pub transferred: u64,
}

impl MoveStructType for SlowWalletResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("DiemAccount");
    const STRUCT_NAME: &'static IdentStr = ident_str!("SlowWallet");
}

impl SlowWalletResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: SlowWalletResource::module_identifier(),
            name: SlowWalletResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(account, SlowWalletResource::struct_tag());
        AccessPath::resource_access_path(resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(SlowWalletResource::struct_tag())
    }

    ///
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        bcs::from_bytes(bytes).map_err(Into::into)
    }
}


/// Struct that represents a SlowWallet resource
#[derive(Debug, Serialize, Deserialize)]
pub struct SlowWalletListResource {
    ///
    pub list: Vec<AccountAddress>,
}

impl MoveStructType for SlowWalletListResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("DiemAccount");
    const STRUCT_NAME: &'static IdentStr = ident_str!("SlowWalletList");
}

impl SlowWalletListResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: SlowWalletListResource::module_identifier(),
            name: SlowWalletListResource::struct_identifier(),
            type_params: vec![],
        }
    }
    ///
    pub fn access_path(account: AccountAddress) -> AccessPath {
        let resource_key = ResourceKey::new(account, SlowWalletListResource::struct_tag());
        AccessPath::resource_access_path(resource_key)
    }
    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(SlowWalletListResource::struct_tag())
    }

    ///
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        bcs::from_bytes(bytes).map_err(Into::into)
    }
}
