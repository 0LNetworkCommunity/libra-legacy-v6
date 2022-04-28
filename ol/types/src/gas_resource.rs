// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

// use crate::access_path::AccessPath;
use diem_types::{
    access_path::AccessPath,
    account_config::{
        self,
        constants::{xus_tag, ACCOUNT_MODULE_IDENTIFIER, CORE_CODE_ADDRESS},
        DIEM_MODULE_IDENTIFIER,
    },
};
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{StructTag, TypeTag},
    move_resource::{MoveResource, MoveStructType},
};
#[cfg(any(test, feature = "fuzzing"))]
use proptest_derive::Arbitrary;
use serde::{Deserialize, Serialize};

/// The balance resource held under an account.
#[derive(Debug, Serialize, Deserialize)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct GasResource {
    value: u64,
}

impl GasResource {
    pub fn new(value: u64) -> Self {
        Self { value }
    }

    pub fn value(&self) -> u64 {
        self.value
    }

    // TODO/XXX: remove this once the MoveResource trait allows type arguments to `struct_tag`.
    pub fn struct_tag() -> StructTag {
        StructTag {
          address: CORE_CODE_ADDRESS,
          name: GasResource::struct_identifier(),
          module: GasResource::module_identifier(),
          type_params: vec![xus_tag()],
      }
    }

    // TODO: remove this once the MoveResource trait allows type arguments to `resource_path`.
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
