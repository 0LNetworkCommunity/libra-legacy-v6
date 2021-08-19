//! oracle upgrade view for cli

use crate::{
    access_path::AccessPath,
    account_config::constants:: CORE_CODE_ADDRESS,
};
use anyhow::Result;
use move_core_types::{
    ident_str,
    identifier::IdentStr,    
    language_storage::StructTag,
    move_resource::{MoveResource, MoveStructType},
};
use serde::{Deserialize, Serialize};
use move_core_types::account_address::AccountAddress;
use sha2::{Digest, Sha256};
/// Struct that represents a Oracles resource
#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct OracleResource {
    ///
    pub upgrade: UpgradeOracle,
}
///
#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct Vote {
    /// voter
    pub validator: AccountAddress,
    /// payload
    // #[serde(with = "hex")]
    pub data: Vec<u8>,
    /// version
    pub version_id: u64,
}

///
#[derive(Debug, Serialize, Deserialize, Clone,PartialEq)]
pub struct VoteCount {
    /// vote payload
    // #[serde(with = "hex")]
    pub data: Vec<u8>,
    /// voters
    pub validators: Vec<AccountAddress>,
}

///
#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
pub struct UpgradeOracle{
    /// id of the upgrade oracle
    pub id: u64,                            // 1
    /// Each validator can only vote once in the current window
    pub validators_voted: Vec<AccountAddress>,  
    /// Stores counts for each suggested payload
    pub vote_counts: Vec<VoteCount>,   
    /// All the received votes  
    pub votes: Vec<Vote>,
    /// End of the current window, in block height          
    pub vote_window: u64,
    /// Version id of the current window      
    pub version_id: u64,
    /// the vote outcome               
    pub consensus: VoteCount,
}


impl UpgradeOracle {
  /// compress the data with sha2
  pub fn compress(&mut self) -> &Self {
    self.vote_counts = self.vote_counts.clone()
    .into_iter()
    .map(|mut i| {
      i.data = Sha256::digest(i.data.as_slice()).to_vec();
      dbg!(&i.data);
      i
    }).collect();

    self.votes = self.votes.clone()
    .into_iter()
    .map(|mut i| {
      i.data = Sha256::digest(i.data.as_slice()).to_vec();
      i
    }).collect();

    self.consensus.data = Sha256::digest(
      self.consensus.data.clone().as_slice()
    ).to_vec(); 
    self
  }
}

impl MoveStructType for OracleResource {
    const MODULE_NAME: &'static IdentStr = ident_str!("Oracle");
    const STRUCT_NAME: &'static IdentStr = ident_str!("Oracles");
}
impl MoveResource for OracleResource {}

impl OracleResource {
    ///
    pub fn struct_tag() -> StructTag {
        StructTag {
            address: CORE_CODE_ADDRESS,
            module: OracleResource::module_identifier(),
            name: OracleResource::struct_identifier(),
            type_params: vec![],
        }
    }

    ///
    pub fn resource_path() -> Vec<u8> {
        AccessPath::resource_access_vec(OracleResource::struct_tag())
    }

    ///
    pub fn try_from_bytes(bytes: &[u8]) -> Result<Self> {
        bcs::from_bytes(bytes).map_err(Into::into)
    }
}
