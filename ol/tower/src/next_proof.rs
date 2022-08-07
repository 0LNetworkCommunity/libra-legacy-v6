//! next proof

use std::path::PathBuf;

use crate::{preimage, proof};
use anyhow::{bail, Error};
use cli::diem_client::DiemClient;
use diem_crypto::HashValue;
use diem_global_constants::genesis_delay_difficulty;
use diem_types::ol_vdf_difficulty::VDFDifficulty;
use ol::{config::AppCfg, node::node::Node};
use ol_types::config::IS_PROD;
use serde::{Deserialize, Serialize};

/// container for the next proof parameters to be fed to VDF prover.
#[derive(Clone, Debug, Deserialize, Serialize)]

pub struct NextProof {
    ///
    pub diff: VDFDifficulty,
    ///
    pub next_height: u64,
    ///
    pub preimage: Vec<u8>,
}

impl NextProof {
    /// create a genesis proof
    pub fn genesis_proof(config: &AppCfg) -> Self {
        let mut diff = VDFDifficulty::default();

        if !*IS_PROD {
            diff.difficulty = genesis_delay_difficulty()
        }

        NextProof {
            diff,
            next_height: 0,
            preimage: preimage::genesis_preimage(config),
        }
    }
}
/// return the VDF difficulty expected and the next tower height
pub fn get_next_proof_params_from_local(config: &AppCfg) -> Result<NextProof, Error> {
    // get the location of this miner's blocks
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_local_block, _) = proof::get_highest_block(&blocks_dir)?;
    let diff = VDFDifficulty {
        difficulty: current_local_block.difficulty(),
        security: current_local_block.security.unwrap(),
        prev_diff: current_local_block.difficulty(),
        prev_sec: current_local_block.security.unwrap(),
    };
    Ok(NextProof {
        diff,
        next_height: current_local_block.height + 1,
        preimage: HashValue::sha3_256_of(&current_local_block.proof).to_vec(),
    })
}

/// query the chain for parameters to use in the next VDF proof.
/// includes global parameters for difficulty
/// and individual parameters like tower height and the preimage (previous proof hash)
pub fn get_next_proof_from_chain(
    config: &mut AppCfg,
    client: DiemClient,
    swarm_path: Option<PathBuf>,
) -> Result<NextProof, Error> {
    // dbg!("pick_client");
    // let client = pick_client(swarm_path.clone(), config)?;

    // dbg!("get user tower state");
    let mut n = Node::new(client, config, swarm_path.is_some());

    n.refresh_onchain_state();
    // TODO: we are picking Client twice
    let diff = get_difficulty_from_chain(&n)?;

    // // get the user's tower state from chain.
    let ts = n
        .client
        .get_account_state(config.profile.account)?
        .get_miner_state()?;

    if let Some(t) = ts {
        Ok(NextProof {
            diff,
            next_height: t.verified_tower_height + 1,
            preimage: t.previous_proof_hash,
        })
    } else {
        bail!("cannot get tower resource for account")
    }
}

/// Get the VDF difficulty from chain.
pub fn get_difficulty_from_chain(n: &Node) -> anyhow::Result<VDFDifficulty> {
    // dbg!("pick_client");
    // let client = pick_client(swarm_path.clone(), config)?;

    // dbg!("get_account_state");

    // let mut n = Node::new(client, config, swarm_path.is_some());

    // // get the user's tower state from chain.
    // let ts = client.get_account_state(config.profile.account)?.get_miner_state()?;

    if let Some(a) = &n.chain_state {
        // let a = client.get_account_state(AccountAddress::ZERO)?;
        // dbg!(&a);
        // dbg!(&a.get_diem_version());
        if let Some(diff) = a.get_tower_params()? {
            return Ok(diff);
        }
        bail!("could not get this epoch's VDF params from chain.")
    }
    bail!("could not get account state for 0x0")
}
