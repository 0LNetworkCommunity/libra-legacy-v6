//! genesis mining proof type

use crate::{account::ValConfigs, config::IS_PROD, fixtures};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
/// State for the genesis transaction
pub struct GenesisMiningProof {
    /// preimage of proof
    pub preimage: String,
    /// proof
    pub proof: String,
    /// user profile
    pub profile: Option<ValConfigs>,
}

// Default is for Swarm and testing
impl Default for GenesisMiningProof {
    fn default() -> GenesisMiningProof {
        // These use "alice" fixtures from ../fixtures/vdf_proofs/ and used elsewhere in the project, in both easy(stage) and hard(Prod) mode.
        let env = if *IS_PROD { "prod" } else { "test" };

        let block = fixtures::get_persona_block_zero("alice", env);
        return GenesisMiningProof {
            preimage: hex::encode(block.preimage),
            proof: hex::encode(block.proof),
            profile: None,
        };
    }
}
