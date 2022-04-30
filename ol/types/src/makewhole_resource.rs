//! The Makewhole on-chain resource
//! 
use diem_types::{
    access_path::AccessPath,
    account_config::constants::{xus_tag, ACCOUNT_MODULE_IDENTIFIER, CORE_CODE_ADDRESS},
};
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::{StructTag, TypeTag},
    move_resource::{MoveResource, MoveStructType},
};
// #[cfg(any(test, feature = "fuzzing"))]
// use proptest_derive::Arbitrary;
use serde::{Deserialize, Serialize};

use crate::gas_resource::GasResource;

/// The balance resource held under an account.
#[derive(Debug, Serialize, Deserialize)]
#[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]
pub struct MakeWholeResource {
  ///
    pub credits: Vec<CreditResource>,
}


#[derive(Debug, Serialize, Deserialize)]
// #[cfg_attr(any(test, feature = "fuzzing"), derive(Arbitrary))]

/// the makewhole credit resource
pub struct CreditResource {
  ///
  pub incident_name: Vec<u8>,
  ///
  pub claimed: bool,
  ///
  pub coins: GasResource,
}

impl MoveStructType for CreditResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("MakeWhole");
    const STRUCT_NAME: &'static IdentStr = ident_str!("Credit");
}

impl MoveResource for CreditResource {}


impl MakeWholeResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            name: MakeWholeResource::struct_identifier(),
            module: MakeWholeResource::module_identifier(),
            type_params: vec![],
        }
    }

    ///
    pub fn access_path_for() -> Vec<u8> {
        AccessPath::resource_access_vec(MakeWholeResource::struct_tag())
    }
}

impl MoveStructType for MakeWholeResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("MakeWhole");
    const STRUCT_NAME: &'static IdentStr = ident_str!("Balance");
}

impl MoveResource for MakeWholeResource {}


