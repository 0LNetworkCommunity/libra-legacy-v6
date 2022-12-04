//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::application::app_config;
use abscissa_core::{Command, Options, Runnable};
use anyhow::{bail, Error};
use diem_types::waypoint::Waypoint;
use std::{fs::File, io::Write, path::PathBuf, process::exit};

/// `files` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct GenesisFilesCmd {
    #[options(help = "id of the chain")]
    chain_id: Option<u8>,
    #[options(help = "github org of genesis repo")]
    github_org: Option<String>,
    #[options(help = "repo with with genesis transactions")]
    repo: Option<String>,
    #[options(help = "use a genesis file instead of building")]
    prebuilt_genesis: Option<PathBuf>,
    #[options(help = "only make fullnode config files")]
    fullnode_only: bool,
    #[options(help = "optional waypoint")]
    waypoint: Option<Waypoint>,
}

impl Runnable for GenesisFilesCmd {
    /// Print version message
    fn run(&self) {
        let miner_configs = app_config().to_owned();
        let home = miner_configs.clone().workspace.node_home;
        if *&self.github_org.is_none() || *&self.repo.is_none() {
            println!(
                "must pass a --github-org and --repo in order to fetch genesis.blob. Exiting."
            );
            exit(1);
        }

        match fetch_genesis_files_from_repo(
        // genesis_files(
            home.clone(),
        //     &self.chain_id,
            &self.github_org,
            &self.repo,
        //     &self.prebuilt_genesis,
        //     &self.fullnode_only,
        //     self.waypoint,
        ) {
            Ok(_) => println!("Success. Files genesis.blob and genesis_waypoint.txs were fetched from {}/{}, and saved to {:?}",&self.github_org.as_ref().unwrap(), &self.repo.as_ref().unwrap(), &home),
            Err(e) => {
              println!("ERROR: could not fetch genesis files from repo, message: {}", e.to_string())
            },
        }
    }
}

// /// create genesis files
// pub fn genesis_files(
//     cfg: &AppCfg,
//     chain_id: &Option<u8>,
//     github_org: &Option<String>,
//     repo: &Option<String>,
//     prebuilt_genesis: &Option<PathBuf>,
//     fullnode_only: &bool,
//     way_opt: Option<Waypoint>,
// ) {
//     let home_dir = cfg.workspace.node_home.to_owned();
//     // 0L convention is for the namespace of the operator to be appended by '-oper'
//     let namespace = cfg.profile.auth_key.clone().to_string() + "-oper";
//     let val_ip_address = cfg.profile.ip;

//     ol_node_files::write_node_config_files(
//         home_dir.clone(),
//         chain_id.unwrap_or(1),
//         github_org.clone(),
//         repo.clone(),
//         &namespace,
//         prebuilt_genesis,
//         fullnode_only,
//         way_opt,
//         &None,
//         Some(val_ip_address),
//     )
//     .unwrap();

//     println!(
//         "validator configurations initialized, file saved to: {:?}",
//         &home_dir.join("validator.node.yaml")
//     );
// }

/// fetch files from github
pub fn fetch_genesis_files_from_repo(
    home_dir: PathBuf,
    github_org: &Option<String>,
    repo: &Option<String>,
) -> Result<PathBuf, Error> {
    let github_org = github_org.clone().unwrap_or("OLSF".to_string());
    let repo = repo.clone().unwrap_or("genesis-registration".to_string());

    let base_url = format!(
        "https://raw.githubusercontent.com/{github_org}/{repo}/main/genesis/",
        github_org = github_org,
        repo = repo
    );

    // let w_res = reqwest::blocking::get(&format!("{}genesis_waypoint.txt", base_url));
    // let w_path = &home_dir.join("genesis_waypoint");
    // let mut w_file = File::create(&w_path)?;
    // let w_content =  w_res.unwrap().text()?;
    // w_file.write_all(w_content.as_bytes())?;
    // println!("genesis waypoint fetched, file saved to: {:?}", w_path);

    let g_res = reqwest::blocking::get(&format!("{}genesis_waypoint.txt", base_url))?;
    match g_res.status().is_success() {
        true => {
            let g_content = g_res.bytes().unwrap().to_vec();
            // default path for genesis.blob
            let g_path = &home_dir.join("genesis_waypoint.txt");
            let mut g_file = File::create(&g_path).expect("couldn't create file");
            g_file.write_all(g_content.as_slice())?;

            println!("genesis_waypoint.txt fetched, file saved to: {:?}", g_path);
        }
        _ => {
            bail!(
                "Cannot fetch genesis_waypoint.txt from Github repo: {}",
                base_url
            );
        }
    };

    let g_res = reqwest::blocking::get(&format!("{}genesis.blob", base_url))?;
    match g_res.status().is_success() {
        true => {
            let g_content = g_res.bytes().unwrap().to_vec();

            // default path for genesis.blob
            let g_path = &home_dir.join("genesis.blob");
            let mut g_file = File::create(&g_path).expect("couldn't create file");
            g_file.write_all(g_content.as_slice())?;

            println!("genesis.blob fetched, file saved to: {:?}", g_path);
            return Ok(g_path.to_owned());
        }
        _ => {
            bail!("Cannot fetch genesis.blob from Github repo: {}", base_url);
        }
    };
}
