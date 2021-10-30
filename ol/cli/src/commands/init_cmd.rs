//! `init` subcommand

#![allow(clippy::never_loop)]

use crate::checkup;
use crate::{application::app_config, config::AppCfg, entrypoint, migrate};
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use anyhow::{bail, Error};
use diem_genesis_tool::{init, key};
use diem_json_rpc_client::AccountAddress;
use diem_types::transaction::authenticator::AuthenticationKey;
use diem_types::waypoint::Waypoint;
use diem_wallet::WalletLibrary;
use fs_extra::file::{copy, CopyOptions};
use ol_keys::{scheme::KeyScheme, wallet};
use ol_types::fixtures;
use std::{fs, path::PathBuf};
use url::Url;

/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    /// home path for app config
    #[options(help = "home path for app config")]
    path: Option<PathBuf>,
    /// An upstream peer to use in 0L.toml
    #[options(help = "An upstream peer to use in 0L.toml")]
    upstream_peer: Option<Url>,
    /// Skip app configs
    #[options(help = "Skip app configs")]
    skip_app: bool,
    /// Skip validator init
    #[options(help = "Skip validator init")]
    skip_val: bool,
    /// run checkup on config file
    #[options(help = "Check config file and give hints if something seems wrong")]
    checkup: bool,
    /// fix the config file
    #[options(help = "Fix config file, and migrate any missing fields")]
    fix: bool,
    /// Set a waypoint in config files
    #[options(help = "Set a waypoint in config files")]
    waypoint: Option<Waypoint>,
    /// Path to source code, for devs
    #[options(help = "Path to source code, for devs")]
    source_path: Option<PathBuf>,
}

impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {
        if *&self.checkup {
            // check 0L.toml file
            checkup::checkup(self.path.to_owned());
            return;
        };

        if *&self.fix {
            // fix 0L.toml file
            migrate::migrate(self.path.to_owned());
            return;
        };

        let entry_args = entrypoint::get_args();
        if let Some(path) = entry_args.swarm_path {
            let swarm_node_home = entrypoint::get_node_home();
            let absolute = fs::canonicalize(path).unwrap();
            initialize_host_swarm(
                absolute,
                swarm_node_home,
                entry_args.swarm_persona,
                &self.source_path,
            )
            .expect("could not initialize host with swarm configs");
            return;
        }

        let (authkey, account, wallet) = wallet::get_account_from_prompt();
        // start with a default value, or read from file if already initialized
        let mut app_cfg = app_config().to_owned();
        if !self.skip_app {
            app_cfg = initialize_app_cfg(
                authkey,
                account,
                &self.upstream_peer,
                &self.path,
                &None, // TODO: probably need an epoch option here.
                &self.waypoint,
                &self.source_path,
            )
            .unwrap()
        };

        if !self.skip_val {
            initialize_validator(&wallet, &app_cfg, self.waypoint, false).unwrap()
        };
    }
}

/// Initializes the necessary 0L config files: 0L.toml
pub fn initialize_app_cfg(
    authkey: AuthenticationKey,
    account: AccountAddress,
    upstream_peer: &Option<Url>,
    path: &Option<PathBuf>,
    epoch_opt: &Option<u64>,
    wp_opt: &Option<Waypoint>,
    source_path: &Option<PathBuf>,
) -> Result<AppCfg, Error> {
    let cfg = AppCfg::init_app_configs(
        authkey,
        account,
        upstream_peer,
        path,
        epoch_opt,
        wp_opt,
        source_path,
        None,
        None,
    );
    Ok(cfg)
}

/// Initializes the necessary 0L config files: 0L.toml and populate blocks directory
/// assumes the libra source is checked out at $HOME/libra
pub fn initialize_host_swarm(
    swarm_path: PathBuf,
    node_home: PathBuf,
    persona: Option<String>,
    source_path: &Option<PathBuf>,
) -> Result<(), Error> {
    let cfg = AppCfg::init_app_configs_swarm(swarm_path, node_home, source_path.clone());
    let p = persona.unwrap_or("alice".to_string());
    let source = fixtures::get_persona_block_zero_path(&p, "test");
    let blocks_dir = PathBuf::new()
        .join(&cfg.workspace.node_home)
        .join(&cfg.workspace.block_dir);
    let target_file = blocks_dir
        .join("proof_0.json");
    println!("copy first block from {:?} to {:?}", &source, &target_file);

    if !&blocks_dir.exists() {
        // first run, create the directory if there is none, or if the user changed the configs.
        // note: user may have blocks but they are in a different directory than what miner.toml says.
        fs::create_dir_all(&blocks_dir).unwrap();
    };

    match copy(&source, target_file, &CopyOptions::new()) {
        Err(why) => {
            println!("copy block failed: {:?}", why);
            bail!(why)
        }
        _ => Ok(()),
    }
}

/// Initializes the necessary validator config files: genesis.blob, key_store.json
pub fn initialize_validator(
    wallet: &WalletLibrary,
    miner_config: &AppCfg,
    way_opt: Option<Waypoint>,
    is_genesis: bool,
) -> Result<(), Error> {
    let home_dir = &miner_config.workspace.node_home;
    let keys = KeyScheme::new(wallet);
    let namespace = miner_config.profile.account.to_hex(); // same format as serializer for 0L/toml
    init::key_store_init(home_dir, &namespace, keys, is_genesis);
    key::set_operator_key(home_dir, &namespace);
    key::set_owner_key(home_dir, &namespace);
    if let Some(way) = way_opt {
        key::set_genesis_waypoint(home_dir, &namespace, way);
        key::set_waypoint(home_dir, &namespace, way);
    }

    Ok(())
}

impl config::Override<AppCfg> for InitCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: AppCfg) -> Result<AppCfg, FrameworkError> {
        Ok(config)
    }
}
