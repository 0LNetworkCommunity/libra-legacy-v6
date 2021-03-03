//! `version` subcommand
#![allow(clippy::never_loop)]

use std::{fs::File, path::{PathBuf}};
use crate::{application::app_config, config::OlCliConfig};
use abscissa_core::{Command, Options, Runnable};
use std::io::Write;
/// `genesis` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct GenesisCmd {
    #[options(help = "application home path")]
    path: Option<PathBuf>,
    #[options(help = "github org of genesis repo")]
    github_org: Option<String>,
    #[options(help = "repo with with genesis transactions")]
    repo: Option<String>,   
}


impl Runnable for GenesisCmd {
    /// Print version message
    fn run(&self) {
        let miner_configs = app_config().to_owned();
        get_files(
            self.path.clone().unwrap_or(PathBuf::from(".")),
            &self.github_org,
            &self.repo,
        ) 
    }
}

pub fn get_files(
    home_dir: PathBuf,
    github_org: &Option<String>,
    repo: &Option<String>
) {
    let github_org = github_org.clone().unwrap_or("OLSF".to_string());
    let repo = repo.clone().unwrap_or("genesis-archive".to_string());


    let base_url = format!(
        "https://raw.githubusercontent.com/{github_org}/{repo}/main/genesis/", github_org=github_org,
        repo=repo
    );

    let w_res = reqwest::blocking::get(&format!("{}genesis_waypoint", base_url));

    let w_path = &home_dir.join("genesis_waypoint");
    let mut w_file = File::create(&w_path).expect("couldn't create file");
    let w_content =  w_res.unwrap().text().unwrap();
    w_file.write_all(w_content.as_bytes()).unwrap();

    let g_res = reqwest::blocking::get(&format!("{}genesis.blob", base_url));

    let g_path = &home_dir.join("genesis.blob");
    let mut g_file = File::create(&g_path).expect("couldn't create file");
    let g_content =  g_res.unwrap().bytes().unwrap().to_vec(); //.text().unwrap();
    g_file.write_all(g_content.as_slice()).unwrap();

    println!("genesis transactions fetched, file saved to: {:?}", g_path);
}