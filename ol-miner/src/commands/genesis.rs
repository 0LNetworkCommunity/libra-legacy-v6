//! `genesis` subcommand

#![allow(clippy::never_loop)]

use super::OlMinerCmd;
use abscissa_core::{Command, Options, Runnable};
use libra_crypto::traits::ValidCryptoMaterial;
use libra_wallet::WalletLibrary;
use std::fs;
use std::io::Write;
use crate::prelude::*;
use crate::block;


#[derive(Command, Debug, Default, Options)]
pub struct GenesisCmd {}

impl Runnable for GenesisCmd {
    fn run(&self) {

        let miner_config = app_config();

        let preimage = miner_config.genesis_preimage();

        let genesis_proof = block::build_block::get_proof(&miner_config, 0);


        

        println!("ol s 0 {} {} {}",hex::encode(preimage),crate::application::DELAY_ITERATIONS,hex::encode(genesis_proof));







    }
    
}
