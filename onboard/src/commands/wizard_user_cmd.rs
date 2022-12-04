//! `version` subcommand

#![allow(clippy::never_loop)]

use abscissa_core::{Command, Options, Runnable};
use anyhow::Error;
use diem_global_constants::{genesis_delay_difficulty, GENESIS_VDF_SECURITY_PARAM};
use ol_keys::wallet;
use ol_types::account;
use ol_types::block::VDFProof;
use ol_types::config::AppCfg;
use std::path::PathBuf;
use tower::{delay, proof::write_genesis};
/// `user wizard` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct UserWizardCmd {
    #[options(help = "path to write account manifest")]
    output_dir: Option<PathBuf>,
    #[options(help = "File to check")]
    check_file: Option<PathBuf>,
    #[options(help = "use an existing proof_0.json file and skip mining")]
    block_zero: Option<PathBuf>,
}

impl Runnable for UserWizardCmd {
    /// Print version message
    fn run(&self) {
        let path = self
            .output_dir
            .clone()
            .unwrap_or_else(|| PathBuf::from("."));

        if let Some(file) = &self.check_file {
            check(file.to_path_buf());
        } else {
            match wizard(path, &self.block_zero) {
                Ok(_) => println!("Success: user account configured"),
                Err(e) => println!(
                    "ERROR: could not configure user, message: {:?}",
                    e.to_string()
                ),
            };
        }
    }
}

fn wizard(path: PathBuf, block_zero: &Option<PathBuf>) -> Result<(), Error> {
    let mut app_cfg = AppCfg::default();

    let (authkey, account, _) = wallet::get_account_from_prompt();

    // Where to save block_0
    app_cfg.workspace.node_home = path.clone();
    app_cfg.profile.auth_key = authkey;
    app_cfg.profile.account = account;

    // Create block zero, if there isn't one.
    let block;
    if let Some(block_path) = block_zero {
        block = VDFProof::parse_block_file(block_path.to_owned());
    } else {
        block = write_genesis(&app_cfg)?;
    }

    // Create Manifest
    account::UserConfigs::new(block).create_manifest(path);
    Ok(())
}

/// Checks the format of the account manifest, including vdf proof
pub fn check(path: PathBuf) -> bool {
    let user_data = account::UserConfigs::get_init_data(&path)
        .expect(&format!("could not parse manifest in {:?}", &path));

    delay::verify(
        &user_data.block_zero.preimage,
        &user_data.block_zero.proof,
        genesis_delay_difficulty(),
        GENESIS_VDF_SECURITY_PARAM as u16,
    )
}
