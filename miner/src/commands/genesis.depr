//! `genesis` subcommand

#![allow(clippy::never_loop)]


use abscissa_core::{Command, Options, Runnable};
use crate::prelude::*;
use crate::block;
use crate::delay::delay_difficulty;


#[derive(Command, Debug, Default, Options)]
pub struct GenesisCmd {}

impl Runnable for GenesisCmd {
    fn run(&self) {

        let miner_config = app_config();

        let preimage = miner_config.genesis_preimage();

        let genesis_proof = block::Block::get_proof(&miner_config, 0);

        //command to run in the libra client to submit a genesis proof.
        println!("Onboarding transaction in libra client.");
        println!("ol s 0 {} {} {}",
            hex::encode(preimage),
            delay_difficulty(),
            hex::encode(genesis_proof)
        );
    }

}
