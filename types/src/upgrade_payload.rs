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

/// Struct that represents a UpgradePayload resource
#[derive(Debug, Serialize, Deserialize)]
pub struct UpgradePayloadResource {
    pub payload: Vec<u8>,
}

impl UpgradePayloadResource {
    /// Constructs an UpgradePayloadResource.
    pub fn new(payload: Vec<u8>) -> Self {
        UpgradePayloadResource {
            payload,
        }
    }
}


impl MoveResource for UpgradePayloadResource {
    const MODULE_NAME: &'static str = "Upgrade";
    const STRUCT_NAME: &'static str = "UpgradePayload";
}

impl UpgradePayloadResource {
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: UpgradePayloadResource::module_identifier(),
            name: UpgradePayloadResource::struct_identifier(),
            type_params: vec![],
        }
    }

    pub fn access_path() -> AccessPath {
        AccessPath::new(CORE_CODE_ADDRESS, UpgradePayloadResource::struct_tag().access_vector())
    }

    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        lcs::from_bytes(bytes).map_err(Into::into)
    }
}
