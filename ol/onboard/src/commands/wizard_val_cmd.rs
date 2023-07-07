//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::wizard;
use abscissa_core::{status_info, status_ok, Command, Options, Runnable};
use diem_types::chain_id::NamedChain;
use diem_types::{waypoint::Waypoint};
use reqwest::Url;
use std::process::exit;
use std::{path::PathBuf};

/// `validator wizard` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValWizardCmd {
    #[options(
        short = "a",
        help = "where to output the account.json file, defaults to node home"
    )]
    output_path: Option<PathBuf>,
    #[options(help = "explicitly set home path instead of answer in wizard, for CI usually")]
    home_path: Option<PathBuf>,
    #[options(help = "id of the chain")]
    chain_id: Option<NamedChain>,
    #[options(help = "github org of genesis repo")]
    github_org: Option<String>,
    #[options(help = "repo with with genesis transactions")]
    repo: Option<String>,
    #[options(help = "use a genesis file instead of building")]
    prebuilt_genesis: Option<PathBuf>,
    #[options(help = "fetching genesis blob from github")]
    fetch_git_genesis: bool,
    #[options(help = "skip mining a block zero")]
    skip_mining: bool,
    #[options(short = "u", help = "template account.json to configure from")]
    template_url: Option<Url>,
    #[options(help = "autopay file if instructions are to be sent")]
    autopay_file: Option<PathBuf>,
    #[options(help = "An upstream peer to use in 0L.toml")]
    upstream_peer: Option<Url>,
    #[options(help = "If validator is building from source")]
    source_path: Option<PathBuf>,
    #[options(short = "w", help = "Explicitly set the waypoint")]
    waypoint: Option<Waypoint>,
    #[options(short = "e", help = "Explicitly set the epoch")]
    epoch: Option<u64>,
    #[options(help = "For testing in ci, use genesis.blob fixtures")]
    ci: bool,
    #[options(help = "Used only on genesis ceremony")]
    genesis_ceremony: bool,
}

impl Runnable for ValWizardCmd {
    fn run(&self) {

      // let w = wizard::Wizard::default();
      
      let w = wizard::OnboardWizard {
        output_path: self.output_path.clone(),
        home_path: self.home_path.clone(),
        chain_id: self.chain_id.clone(),
        github_org: self.github_org.clone(),
        repo: self.repo.clone(),
        prebuilt_genesis: self.prebuilt_genesis.clone(),
        fetch_git_genesis: self.fetch_git_genesis,
        skip_mining: self.skip_mining,
        template_url: self.template_url.clone(),
        autopay_file: self.autopay_file.clone(),
        upstream_peer: self.upstream_peer.clone(),
        source_path: self.source_path.clone(),
        waypoint: self.waypoint.clone(),
        epoch: self.epoch.clone(),
        ci: self.ci,
        genesis_ceremony: self.genesis_ceremony,
      };

        match w.run() {
            Ok(_) => status_ok!("Success", "validator configured"),
            Err(e) => {
                status_info!("ERROR", "could not configure validator, message: {:?}", e);
                exit(1);
            }
      }


    }
}
