//! GAS resource struct for parsing chain state

use diem_types::{
    access_path::AccessPath,
    account_config::{
        constants::CORE_CODE_ADDRESS,
    },
};
use move_core_types::{
    ident_str,
    identifier::IdentStr,
    language_storage::StructTag,
    move_resource::{MoveResource, MoveStructType},
};
use serde::{Deserialize, Serialize};

/// difficulty of the VDF proof, for use as on-chain representation and in `tower`
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct VDFDifficulty {
    /// Difficulty
    pub difficulty: u64,
    /// Security parameter for VDF
    pub security: u64,
}


impl VDFDifficulty {

    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
          address: CORE_CODE_ADDRESS,
          name: VDFDifficulty::struct_identifier(),
          module: VDFDifficulty::module_identifier(),
          type_params: vec![],
      }
    }

    ///
    pub fn access_path_for() -> Vec<u8> {
        AccessPath::resource_access_vec(VDFDifficulty::struct_tag())
    }
}

impl MoveStructType for VDFDifficulty {
    const MODULE_NAME: &'static IdentStr = ident_str!("Tower");
    const STRUCT_NAME: &'static IdentStr = ident_str!("VDFDifficulty");
}

impl MoveResource for VDFDifficulty {}
