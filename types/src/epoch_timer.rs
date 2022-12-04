//! autopay view for web monitor

use anyhow::Result;
use diem_types::{
    access_path::AccessPath,
    account_config::constants::CORE_CODE_ADDRESS,
    write_set::{WriteOp, WriteSetMut},
};
use move_core_types::account_address::AccountAddress;
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{ResourceKey, StructTag},
    move_resource::{MoveResource, MoveStructType},
};
use serde::{Deserialize, Serialize};

/// Struct that represents a AutoPay resource
#[derive(Debug, Serialize, Deserialize)]
pub struct EpochTimerResource {
    ///
    pub epoch: u64,
    ///
    pub height_start: u64,
    ///
    pub seconds_start: u64,
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
        let resource_key = ResourceKey::new(account, EpochTimerResource::struct_tag());
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
    /// make a writeset for this struct
    pub fn to_writeset(&self) -> Result<WriteSetMut> {
        let op = WriteOp::Value(bcs::to_bytes(self)?);
        let unit = (EpochTimerResource::access_path(AccountAddress::ZERO), op);
        Ok(WriteSetMut::new(vec![unit]))
    }
}

#[test]
pub fn test_changeset() {
    let e = EpochTimerResource {
        epoch: 1,
        height_start: 2,
        seconds_start: 3,
    };
    e.to_writeset().unwrap();
}
