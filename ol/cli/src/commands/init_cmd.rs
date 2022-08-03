//! `init` subcommand

#![allow(clippy::never_loop)]

use crate::{
    application::app_config,
    config::AppCfg,
    entrypoint,
    node::{client, node::Node},
};
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use anyhow::{bail, Error};
use dialoguer::Confirm;
use diem_genesis_tool::{init, key, ol_node_files};
use diem_types::account_address::AccountAddress;
use diem_types::transaction::authenticator::AuthenticationKey;
use diem_types::waypoint::Waypoint;
use diem_wallet::WalletLibrary;
use fs_extra::file::{copy, CopyOptions};
use ol_keys::{scheme::KeyScheme, wallet};
use ol_types::{config::fix_missing_fields, fixtures, rpc_playlist};
use std::process::exit;
use std::{fs, path::PathBuf};
use url::Url;
/// `init` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct InitCmd {
    /// Create the 0L.toml file for 0L apps
    #[options(help = "Create the 0L.toml file for 0L apps")]
    app: bool,

    /// An upstream peer to use in 0L.toml
    #[options(help = "An upstream peer to use in 0L.toml")]
    rpc_peer: Option<Url>,    

    /// home path for app config
    #[options(help = "home path for app config")]
    app_cfg_path: Option<PathBuf>,

    /// Create validator yaml file configuration
    #[options(help = "Create validator.node.yaml file configuration")]
    val: bool,

    /// Create validator yaml file configuration
    #[options(help = "Create vfn.node.yaml file configuration")]
    vfn: bool,

    /// Create fullnode.node.yaml file configuration
    #[options(help = "Create fullnode.node.yaml file configuration")]
    fullnode: bool,

    /// Set the upstream peers playlist from an http served playlist file
    #[options(
        help = "Use a playlist.json file hosted online to set the upstream_peers field in 0L.toml"
    )]
    rpc_playlist: Option<String>, // Using string so that the user can use a default upstream

    /// Search and get seed peers from chain
    #[options(help = "Get seed fullnode peers from chain")]
    seed_peer: bool,

    /// Init key store file for validator
    #[options(help = "Init key store file for validator")]
    key_store: bool,

    /// run checkup on config file
    #[options(help = "Check config file and give hints if something seems wrong")]
    checkup: bool,

    /// fix the config file
    #[options(help = "Fix config file, and migrate any missing fields")]
    fix: bool,

    /// Set a waypoint in config files
    #[options(help = "Set from CLI or get waypoint from chain")]
    update_waypoint: bool,

    /// Set a waypoint in config files
    #[options(help = "Manually set a waypoint. ")]
    waypoint: Option<Waypoint>,

    /// Path to source code, for devs
    #[options(help = "Path to source code, for devs")]
    source_path: Option<PathBuf>,
}

impl Runnable for InitCmd {
    /// Print version message
    fn run(&self) {

        // TODO: This has no effect. This command will not load if the 0L.toml is malformed.
        // this is an Abscissa issue.
        // even with serde deny_unknown disabled the app will crash.
        if self.app_cfg_path.is_some() && self.fix {
            match fix_missing_fields(self.app_cfg_path.as_ref().unwrap().to_owned()) {
                Ok(_) => println!("0L.toml has up-to-date schema"),
                Err(e) => println!("could not update 0L.toml schema, exiting. Message: {:?}", e),
            };
            return;
        }

        // start with a default value, or read from file if already initialized
        let mut app_cfg = app_config().to_owned();
        let entry_args = entrypoint::get_args();
        let is_swarm = *&entry_args.swarm_path.is_some();

        if self.update_waypoint {
            // TODO: will need to update the key_store.json file with waypoint info.
            if let Some(w) = self.waypoint {
                app_cfg.chain_info.base_waypoint = Some(w);
                match app_cfg.save_file() {
                    Ok(_) => {}
                    Err(e) => {
                        println!("could not save config file, exiting. Message: {:?}", e);
                        exit(1)
                    }
                }
                return;
            };
            let client = match client::pick_client(entry_args.swarm_path.clone(), &mut app_cfg) {
                Ok(c) => c,
                Err(e) => {
                    println!(
                        "Could not connect to a fullnode with JSON API, exiting. Message: {:?}",
                        e
                    );
                    exit(1);
                }
            };

            let mut node = Node::new(client, &app_cfg, is_swarm);

            match node.waypoint() {
                Ok(w) => {
                    key::set_waypoint(
                        &app_cfg.workspace.node_home,
                        &app_cfg.profile.account.to_string(),
                        w,
                    );
                    key::set_genesis_waypoint(
                        &app_cfg.workspace.node_home,
                        &app_cfg.profile.account.to_string(),
                        w,
                    );

                    app_cfg.chain_info.base_waypoint = Some(w);
                    match app_cfg.save_file() {
                        Ok(_) => {}
                        Err(e) => {
                            println!("could not save config file, exiting. Message: {:?}", e);
                            exit(1)
                        }
                    }
                    return;
                }
                Err(e) => {
                    println!("Could not find a waypoint, exiting. Message: {:?}", e);
                    exit(1);
                }
            }
        }

        if let Some(url) = self.rpc_playlist.as_ref() {
            // try to parse it, otherwise get_known_fullnodes will use a default playlist
            let playlist_url: Option<Url> = url.parse().ok();

            match rpc_playlist::get_known_fullnodes(playlist_url) {
                Ok(f) => {
                    println!("peers found:");
                    f.get_urls()
                        .into_iter()
                        .for_each(|u| println!("{}", u.as_str()));

                    match f.update_config_file(self.app_cfg_path.clone()) {
                        Ok(_) => println!("Upstream RPC peers updated in 0L.toml"),
                        Err(e) => {
                            println!(
                                "could not update rpc peers in config file, exiting. Message: {:?}",
                                e
                            );
                            exit(1);
                        }
                    }
                    return;
                }
                Err(e) => {
                    println!(
                        "could not read playlists from {:?}, exiting. Message: {:?}",
                        url, e
                    );
                    exit(1);
                }
            };
        }
        
        // fetch a list of seed peers from the current on chain discovery
        // doesn't need mnemonic
        if self.seed_peer {
            let client = match client::pick_client(entry_args.swarm_path.clone(), &mut app_cfg) {
                Ok(c) => c,
                Err(e) => {
                    println!(
                        "Could not connect to a fullnode with JSON API, exiting. Message: {:?}",
                        e
                    );
                    exit(1);
                }
            };

            let mut node = Node::new(client, &app_cfg, is_swarm);

            match node.refresh_fullnode_seeds() {
                Ok(s) => {
                    match serde_yaml::to_string(&s) {
                        Ok(y) => {
                            let path = app_cfg.workspace.node_home.join("seed_fullnodes.yaml");
                            match std::fs::write(&path, &y) {
                                Ok(_) => {
                                    println!("seed_fullnodes.yaml file written to: {:?}", &path)
                                }
                                Err(e) => {
                                    println!(
                                        "Could not write yaml file, exiting. Message: {:?}",
                                        e
                                    );
                                    exit(1);
                                }
                            };
                        }
                        Err(e) => {
                            println!("Could not serialize yaml, exiting. Message: {:?}", e);
                            exit(1);
                        }
                    }
                    // return
                }
                Err(e) => {
                    println!(
                        "Could not fetch seed peers from chain, exiting. Message: {:?}",
                        e
                    );
                    exit(1);
                }
            };

            exit(0);
        }

        // create files for VFN
        if self.vfn {
            println!("Creating vfn.node.yaml file.");

            let namespace = app_cfg.format_oper_namespace();
            let output_dir = app_cfg.workspace.node_home;
            let val_ip_address = app_cfg.profile.ip;
            let gen_wp = app_cfg.chain_info.base_waypoint;

            match ol_node_files::make_vfn_file(
                output_dir,
                val_ip_address,
                gen_wp.unwrap_or_default(),
                &namespace,
            ) {
                Ok(_) => {}
                Err(e) => {
                    println!("Could not create file, exiting. Message: {:?}", e);
                    exit(1);
                }
            };
            return;
        }

        // create files for val
        if self.val {
            println!("Creating validator.node.yaml file. This assumes you have a key_store.json. If you do not, run this command again with --key-store");

            // TODO: check we can open key-store file

            let namespace = app_cfg.format_oper_namespace();
            let output_dir = app_cfg.workspace.node_home;

            match ol_node_files::make_val_file(output_dir, None, &namespace) {
                Ok(_) => {}
                Err(e) => {
                    println!("Could not create file, exiting. Message: {:?}", e);
                    exit(1);
                }
            };
            return;
        }

        // create files for public fullnode
        if self.fullnode {
            println!("Creating fullnode.node.yaml file.");

            // TODO: check we can open key-store file
            let output_dir = app_cfg.workspace.node_home;
            let gen_wp = app_cfg.chain_info.base_waypoint;

            // TODO: get seed addresses from file optionally
            // let seed = SeedAddresses::read_from_file(seed_peers_path);

            match ol_node_files::make_fullnode_file(output_dir, None, gen_wp.unwrap_or_default()) {
                Ok(_) => {}
                Err(e) => {
                    println!("Could not create file, exiting. Message: {:?}", e);
                    exit(1);
                }
            };
            return;
        }

        // Can also initializes users for swarm and tests.
        if let Some(path) = entry_args.swarm_path {
            let swarm_node_home = entrypoint::get_node_home();
            let absolute = fs::canonicalize(path).unwrap();
            initialize_host_swarm(
                absolute,
                swarm_node_home,
                entry_args.swarm_persona,
                &self.source_path,
            )
            .unwrap_or_else(|e| {
                println!(
                    "could not initialize host with swarm configs, exiting. Message: {:?}",
                    &e
                );
                exit(1);
            });
            return;
        }

        /////////// Everything below requires mnemonic ////////
        let (authkey, account, wallet) = wallet::get_account_from_prompt();

        // now we can modify the 0L.toml from template.
        if self.app {
            // note this will overwrite the 0L.toml
            // check the user wants to do this.
            match Confirm::new()
                .with_prompt("This will overwrite an 0L.toml file if it exists. Proceed?")
                .interact()
            {
                Ok(t) => {
                    if t {
                        initialize_app_cfg(
                            authkey,
                            account,
                            &self.rpc_peer,
                            &self.app_cfg_path,
                            &None, // TODO: probably need an epoch option here.
                            &self.waypoint,
                            &self.source_path,
                        )
                        .unwrap_or_else(|e| {
                            println!(
                                "could not initialize app configs 0L.toml, exiting. Message: {:?}",
                                &e
                            );
                            exit(1);
                        });
                    }
                }
                Err(_) => {}
            };
            return;
        };

        // TODO: this should happen before --val since the user may want to do two operations in one command. But we'll need to authenticate them for this step. --val doesn't neet authentication.
        if self.key_store {
            initialize_val_key_store(&wallet, &app_cfg, self.waypoint, false).unwrap();
            return;
        };
    }
}

/// Initializes the necessary 0L config files: 0L.toml
pub fn initialize_app_cfg(
    authkey: AuthenticationKey,
    account: AccountAddress,
    rpc_peer: &Option<Url>,
    path: &Option<PathBuf>,
    epoch_opt: &Option<u64>,
    wp_opt: &Option<Waypoint>,
    source_path: &Option<PathBuf>,
) -> Result<AppCfg, Error> {
    let cfg = AppCfg::init_app_configs(
        authkey,
        account,
        rpc_peer,
        path,
        epoch_opt,
        wp_opt,
        source_path,
        None,
        None,
    )
    .unwrap_or_else(|e| {
        println!("could not create app configs, exiting. Message: {:?}", &e);
        exit(1);
    });
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
    let cfg = AppCfg::init_app_configs_swarm(swarm_path, node_home, source_path.clone())?;
    let p = persona.unwrap_or("alice".to_string());
    let source = fixtures::get_persona_block_zero_path(&p, "test");
    let blocks_dir = PathBuf::new()
        .join(&cfg.workspace.node_home)
        .join(&cfg.workspace.block_dir);
    let target_file = blocks_dir.join("proof_0.json");
    println!("copy first block from {:?} to {:?}", &source, &target_file);

    if !&blocks_dir.exists() {
        // first run, create the directory if there is none, or if the user
        // changed the configs.
        // note: user may have blocks but they are in a different directory
        // than what miner.toml says.
        fs::create_dir_all(&blocks_dir).unwrap_or_else(|e| {
            println!(
                "could not create directory for vdf proofs, exiting. Message: {:?}",
                &e
            );
            exit(1);
        })
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
pub fn initialize_val_key_store(
    wallet: &WalletLibrary,
    app_cfg: &AppCfg,
    way_opt: Option<Waypoint>,
    is_genesis: bool,
) -> Result<(), Error> {
    let home_dir = &app_cfg.workspace.node_home;
    let keys = KeyScheme::new(wallet);
    let namespace = app_cfg.format_oper_namespace();
    let way = way_opt.unwrap_or(
        "0:c12c01d2ac6deb028567c9a9c816ca3fe53fab9c461e4eab2f89125f975b63c3"
            .parse()
            .unwrap(),
    );

    init::key_store_init(home_dir, &namespace, keys, is_genesis);
    key::set_operator_key(home_dir, &namespace);
    key::set_owner_key(home_dir, &namespace, app_cfg.profile.account);
    key::set_genesis_waypoint(home_dir, &namespace, way.clone());
    key::set_waypoint(home_dir, &namespace, way);

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
