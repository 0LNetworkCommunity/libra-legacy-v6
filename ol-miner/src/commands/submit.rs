//! `submit` subcommand


use abscissa_core::{Command, Options, Runnable};
use crate::prelude::*;
use libra_types::waypoint::Waypoint;
use rustyline::error::ReadlineError;
use rustyline::Editor;
use crate::block::*;
use anyhow::Error;



#[derive(Command, Debug, Default, Options)]
pub struct SubmitCmd {
    #[options(help = "Provide a waypoint for the libra chain")]
    waypoint: String, //Option<Waypoint>,

    #[options(help = "Already mined height to submit")]
    height: usize,
}

impl Runnable for SubmitCmd {
    fn run(&self) {
        let miner_configs = app_config();

        let mut rl = Editor::<()>::new();

        println!("Enter your 0L mnemonic");

        let readline = rl.readline(">> ");


        match readline {
            Ok(line) => {
                println!("Mnemonic: \n{}", line);

                let parsed_waypoint: Result<Waypoint, Error> = self.waypoint.parse();
                match parsed_waypoint {
                    Ok(v) => {
                        println!("Using Waypoint from CLI args:\n{}", v);
                    }
                    Err(_e) => {
                        println!("Waypoint cannot be parsed, check delimiter: Error:\n{:?}\n WILL FALLBACK TO WAYPOINT FROM ol_miner.toml", miner_configs.chain_info.base_waypoint);
                        return;
                    }
                }

                let result = build_block::submit_block(&miner_configs, line, parsed_waypoint.unwrap(),self.height);
                match result {
                    Ok(_val) => { }
                    Err(_) => {
                        println!("Failed to submit block")
                    }
                }
            }
            Err(ReadlineError::Interrupted) => {
                println!("CTRL-C");
            }
            Err(ReadlineError::Eof) => {
                println!("CTRL-D");
            }
            Err(err) => {
                println!("Error: {:?}", err);
            }
        }

    }
}