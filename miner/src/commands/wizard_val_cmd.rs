//! `version` subcommand

#![allow(clippy::never_loop)]

use super::{files_cmd, keygen_cmd, manifest_cmd, zero_cmd};
use crate::entrypoint;
use abscissa_core::{status_info, status_ok, Command, Options, Runnable};
use ol_cli::commands::init_cmd;
use ol_util::autopay::{self, Instruction};
use reqwest::Url;
use std::{fs::File, io::Write, path::PathBuf};
/// `val-wizard` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ValWizardCmd {
  #[options(help = "home path for all 0L files")]
  path: Option<PathBuf>,
  #[options(help = "id of the chain")]
  chain_id: Option<u8>,
  #[options(help = "github org of genesis repo")]
  github_org: Option<String>,
  #[options(help = "repo with with genesis transactions")]
  repo: Option<String>,
  #[options(help = "run keygen before wizard")]
  keygen: bool,
  #[options(help = "build genesis from ceremony repo")]
  rebuild_genesis: bool,
  #[options(help = "skip fetching genesis blob")]
  skip_fetch_genesis: bool,
  #[options(help = "skip mining a block zero")]
  skip_mining: bool,
  #[options(help = "template account.json to configure from")]
  template_url: Option<Url>,
  #[options(help = "template account.json to configure from")]
  autopay_file: Option<PathBuf>,
}

impl Runnable for ValWizardCmd {
  /// Print version message
  fn run(&self) {
    let entry_args = entrypoint::get_args();

    // Keygen
    if self.keygen {
      keygen_cmd::generate_keys();
      status_ok!("\nKeys generated", "\n...........................\n");
    }

    status_info!("\nValidator Config Wizard.", "Next you'll enter your mnemonic and some other info to configure your validator node and on-chain account. If you haven't yet generated keys you can re-run this command with the flag '--keygen', or run the standalone keygen subcommand with 'miner keygen'.\n\nYour first 0L proof-of-work will be mined now. Expect this to take up to 15 minutes on modern CPUs.\n");

    // Get credentials from prompt
    let (authkey, account, wallet) = keygen::account_from_prompt();

    // Initialize Miner
    // Need to assign miner_config, because reading from app_config can only be done at startup, and it will be blank at the time of wizard executing.
    let miner_config =
      init_cmd::initialize_miner(authkey, account, &self.path, entry_args.swarm_path)
        .unwrap();
    let home_path = &miner_config.workspace.node_home;
    status_ok!("\nMiner config written", "\n...........................\n");

    if let Some(url) = &self.template_url {
      let g_res = reqwest::blocking::get(&url.to_string());
      let g_path = home_path.join("template.json");
      let mut g_file = File::create(&g_path).expect("couldn't create file");
      let g_content = g_res.unwrap().bytes().unwrap().to_vec(); //.text().unwrap();
      g_file.write_all(g_content.as_slice()).unwrap();
      // get autopay
      status_ok!("\nTemplate fetched", "\n...........................\n");
    }
    // Initialize Validator Keys
    init_cmd::initialize_validator(&wallet, &miner_config).unwrap();
    status_ok!("\nKey file written", "\n...........................\n");

    // fetching the genesis files from genesis-archive
    // unless we are skipping it, or unless we intend to rebuild.
    if !self.skip_fetch_genesis {
      // if we are rebuilding genesis then we should skip fetching files
      if !self.rebuild_genesis {
        files_cmd::get_files(home_path.to_owned(), &self.github_org, &self.repo);
        status_ok!(
          "\nDownloaded genesis files",
          "\n...........................\n"
        );
      }
    }

    // Build Genesis and node.yaml file
    files_cmd::genesis_files(
      &miner_config,
      &self.chain_id,
      &self.github_org,
      &self.repo,
      &self.rebuild_genesis,
      &false,
    );
    status_ok!("\nNode config written", "\n...........................\n");

    if !self.skip_mining {
      // Mine Block
      zero_cmd::mine_zero(&miner_config);
      status_ok!(
        "\nGenesis proof complete",
        "\n...........................\n"
      );
    }

    let autopay_batch = autopay_batch(&self.template_url, &self.autopay_file, home_path);
    // Write Manifest
    manifest_cmd::write_manifest(
      &self.path,
      wallet,
    Some(miner_config),
    autopay_batch);
    status_ok!(
      "\nAccount manifest written",
      "\n...........................\n"
    );

    status_info!("Your validator node and miner app are now configured.", "The account.json can be used to submit an account creation transaction on-chain. Someone with an existing account (with GAS) can do this for you.");
  }
}

fn autopay_batch(
  template: &Option<Url>,
  file_path: &Option<PathBuf>,
  home_path: &PathBuf,
) -> Option<Vec<Instruction>> {
  let file_name = if let Some(url) = template {
    "template.json"
  } else if let Some(path) = file_path {
    path.to_str().unwrap()
  } else {
    "autopay.json"
  };
  Some(autopay::get_instructions(&home_path.join(file_name)))
}
