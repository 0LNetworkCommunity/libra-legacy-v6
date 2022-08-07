//! GAS resource struct for parsing chain state

use diem_types::{
    access_path::AccessPath,
    account_config::{
        constants::{xus_tag, CORE_CODE_ADDRESS},
        DIEM_MODULE_IDENTIFIER,
    },
};
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{StructTag, TypeTag},
    move_resource::{MoveResource, MoveStructType},
};
use serde::{Deserialize, Serialize};

/// The balance resource held under an account.
#[derive(Debug, Serialize, Deserialize)]
/// The GAS coin resource
pub struct GasResource {
    ///
    pub value: u64,
}

impl GasResource {
    ///
    pub fn new(value: u64) -> Self {
        Self { value }
    }

    ///
    pub fn value(&self) -> u64 {
        self.value
    }

    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            name: GasResource::struct_identifier(),
            module: GasResource::module_identifier(),
            type_params: vec![xus_tag()],
        }
    }

    ///
    pub fn access_path_for() -> Vec<u8> {
        AccessPath::resource_access_vec(GasResource::struct_tag())
    }
}

impl MoveStructType for GasResource {
    const MODULE_NAME: &'static IdentStr = DIEM_MODULE_IDENTIFIER;
    const STRUCT_NAME: &'static IdentStr = ident_str!("Diem");

    fn type_params() -> Vec<TypeTag> {
        vec![xus_tag()]
    }
}

impl MoveResource for GasResource {}
