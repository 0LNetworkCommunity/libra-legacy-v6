//! GAS resource struct for parsing chain state

use crate::{
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
    /// Previous epoch's difficulty
    pub prev_diff: u64,
    /// Previous epoch's security param
    pub prev_sec: u64,
}


impl VDFDifficulty {
    /// get the difficulty/iterations of the block, or assume legacy
    pub fn difficulty(&self) -> u64 {
      self.difficulty
    }

    /// get the security param of the block, or assume legacy
    pub fn security(&self) -> u64 {
      self.security
    }
    
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
    const MODULE_NAME: &'static IdentStr = ident_str!("TowerState");
    const STRUCT_NAME: &'static IdentStr = ident_str!("VDFDifficulty");
}

impl MoveResource for VDFDifficulty {}

impl Default for VDFDifficulty {
    fn default() -> Self {
        Self { 
          difficulty: 5_000_000,  // historical value from genesis
          security: 512, // historical value from genesis 
          prev_diff: 5_000_000,
          prev_sec: 512,
        }
    }
}