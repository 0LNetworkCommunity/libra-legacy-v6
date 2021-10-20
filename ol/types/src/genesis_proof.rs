//! genesis mining proof type

use crate::{account::ValConfigs, config::IS_PROD, fixtures};
use serde::{Deserialize, Serialize};

//////// 0L ////////
// 0L Change: Necessary for genesis transaction.
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct GenesisMiningProof {
    /// preimage of proof
    pub preimage: String,
    /// proof
    pub proof: String,
    /// user profile
    pub profile: Option<ValConfigs>,
}

//////// 0L ////////
impl Default for GenesisMiningProof {
    fn default() -> GenesisMiningProof {
        // These use "alice" fixtures from ../fixtures/blocks/ and used elsewhere in the project, in both easy(stage) and hard(Prod) mode.
        let env = if *IS_PROD {
          "prod";
        } else {
          "test"
        };

        let block = fixtures::get_persona_block_zero("alice", env);
        return GenesisMiningProof {
            preimage: hex::encode(block.preimage),
            proof: hex::encode(block.proof),
            profile: None,
        };
    }
}