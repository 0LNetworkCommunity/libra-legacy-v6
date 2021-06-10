//! `version` subcommand

#![allow(clippy::never_loop)]

use ol_keys::wallet;
use ol_types::block::Block;
use miner::{delay, block::write_genesis};
use ol_types::config::AppCfg;
use abscissa_core::{Command, Options, Runnable};
use std::{path::PathBuf};
use ol_types::account;
/// `user-wizard` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct UserWizardCmd {
    #[options(help = "path to write account manifest")]
    output_dir: Option<PathBuf>,
    #[options(help = "File to check")]
    check_file: Option<PathBuf>,
    #[options(help = "use an existing block_0.json file and skip mining")]
    block_zero: Option<PathBuf>,
}

impl Runnable for UserWizardCmd {
    /// Print version message
    fn run(&self) {
        // let miner_configs = app_config();
        let path = self.output_dir.clone().unwrap_or_else(|| PathBuf::from("."));
        
        if let Some(file) = &self.check_file {
            check(file.to_path_buf());
        } else {
            wizard(path, &self.block_zero);
        }
    }
}

fn wizard(path: PathBuf, block_zero: &Option<PathBuf>) {
    let mut app_cfg = AppCfg::default();
    
    let (authkey, account, _) = wallet::get_account_from_prompt();

    // Where to save block_0
    app_cfg.workspace.node_home = path.clone();
    app_cfg.profile.auth_key = authkey.to_string();
    app_cfg.profile.account = account;

    // Create block zero, if there isn't one.
    let block;
    if let Some(block_path) = block_zero {
        block = Block::parse_block_file(block_path.to_owned());
    } else {
        block = write_genesis(&app_cfg);
    }

    // Create Manifest
    account::UserConfigs::new(block)
    .create_manifest(path);
}

/// Checks the format of the account manifest, including vdf proof
fn check(path: PathBuf) {
    let user_data = account::UserConfigs::get_init_data(&path).expect(&format!("could not parse manifest in {:?}", &path));

    match delay::verify(&user_data.block_zero.preimage, &user_data.block_zero.proof) {
        true => println!("Proof verified in {:?}", &path),
        false => println!("Invalid proof in {:?}", &path)
    }
}
