//! `version` subcommand

#![allow(clippy::never_loop)]

use ol_types::{block::Block};
use crate::prelude::app_config;
use super::{files_cmd};

use abscissa_core::{status_info, status_ok, Command, Options, Runnable};
// use libra_genesis_tool::keyscheme::KeyScheme;
use keygen::scheme::KeyScheme;

use libra_types::{transaction::SignedTransaction, waypoint::Waypoint};
use libra_wallet::WalletLibrary;
use ol_cli::{commands::init_cmd, config::AppCfg};
use ol_types::{account::ValConfigs, autopay::PayInstruction, config::TxType};
use reqwest::Url;
use serde_json::Value;
use std::{fs::File, io::Write, path::PathBuf};
use txs::{commands::autopay_batch_cmd, submit_tx};
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
    #[options(help = "build genesis from ceremony repo")]
    rebuild_genesis: bool,
    #[options(help = "skip fetching genesis blob")]
    skip_fetch_genesis: bool,
    #[options(help = "skip mining a block zero")]
    skip_mining: bool,
    #[options(short = "u", help = "template account.json to configure from")]
    template_url: Option<Url>,
    #[options(help = "template account.json to configure from")]
    autopay_file: Option<PathBuf>,
    #[options(help = "An upstream peer to use in 0L.toml")]
    upstream_peer: Option<Url>,
}

impl Runnable for ValWizardCmd {
    /// Print version message
    fn run(&self) {
        status_info!("\nValidator Config Wizard.", "Next you'll enter your mnemonic and some other info to configure your validator node and on-chain account. If you haven't yet generated keys, run the standalone keygen tool with 'ol keygen'.\n\nYour first 0L proof-of-work will be mined now. Expect this to take up to 15 minutes on modern CPUs.\n");

        // Get credentials from prompt
        let (authkey, account, wallet) = keygen::account_from_prompt();

        // Initialize Miner
        // Need to assign app_config, otherwise abscissa would use the default.
        let mut app_config = AppCfg::init_app_configs(
                              authkey,
                              account,
                              &self.upstream_peer,
                              &self.path
                            );

        let home_path = &app_config.workspace.node_home;
        status_ok!("\nMiner config written", "\n...........................\n");

        if let Some(url) = &self.template_url {
            save_template(&url.join("account.json").unwrap(), home_path);
            let (epoch, wp) = get_epoch_info(&url.join("epoch.json").unwrap());

            app_config.chain_info.base_epoch = epoch;
            app_config.chain_info.base_waypoint = wp;
            // get autopay
            status_ok!("\nTemplate saved", "\n...........................\n");
        }

        // Use any autopay instructions
        // TODO: simplify signature
        let (autopay_batch, autopay_signed) = get_autopay_batch(
            &self.template_url,
            &self.autopay_file,
            home_path,
            &app_config,
            &wallet,
        );
        status_ok!("\nAutopay transactions signed", "\n...........................\n");

        // Initialize Validator Keys
        init_cmd::initialize_validator(&wallet, &app_config).unwrap();
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

        // // Build Genesis and node.yaml file
        // files_cmd::node_config_files(
        //     &cfg,
        //     &self.chain_id,
        //     &self.github_org,
        //     &self.repo,
        //     &self.rebuild_genesis,
        //     &false,
        // );

        let home_dir = app_config.workspace.node_home.to_owned();
        // 0L convention is for the namespace of the operator to be appended by '-oper'
        let namespace = app_config.profile.auth_key.clone() + "-oper";

        // TODO: use node_config to get the seed peers and then write upstream_node vec in 0L.toml from that.
        node_files::write_node_config_files(
            home_dir.clone(),
            self.chain_id.unwrap_or(1),
            &self.github_org.clone().unwrap_or("OLSF".to_string()),
            &self
                .repo
                .clone()
                .unwrap_or("experimental-genesis".to_string()),
            &namespace,
            &self.rebuild_genesis,
            &false,
        )
        .unwrap();

        status_ok!("\nNode config written", "\n...........................\n");

        if !self.skip_mining {
            // Mine Block
            miner::block::write_genesis(&miner_config);
            status_ok!(
                "\nGenesis proof complete",
                "\n...........................\n"
            );
        }

        // Write Manifest
        write_manifest(
            &self.path,
            wallet,
            Some(app_config),
            autopay_batch,
            autopay_signed,
        );
        status_ok!(
            "\nAccount manifest written",
            "\n...........................\n"
        );

        status_info!("Your validator node and miner app are now configured.", "The account.json can be used to submit an account creation transaction on-chain. Someone with an existing account (with GAS) can do this for you.");
    }
}

fn get_autopay_batch(
    template: &Option<Url>,
    file_path: &Option<PathBuf>,
    home_path: &PathBuf,
    cfg: &AppCfg,
    wallet: &WalletLibrary,
) -> (Option<Vec<PayInstruction>>, Option<Vec<SignedTransaction>>) {
    let file_name = if template.is_some() {
        "template.json"
    } else if let Some(path) = file_path {
        path.to_str().unwrap()
    } else {
        "autopay.json"
    };

    let starting_epoch = cfg.chain_info.base_epoch.unwrap();
    let instr_vec = PayInstruction::parse_autopay_instructions(&home_path.join(file_name));
    let script_vec = autopay_batch_cmd::process_instructions(instr_vec.clone(), starting_epoch);
    let url = cfg.what_url(false);
    let tx_params =
        submit_tx::get_tx_params_from_toml(cfg.to_owned(), TxType::Miner, Some(wallet), url)
            .unwrap();
    let txn_vec = autopay_batch_cmd::sign_instructions(script_vec, 0, &tx_params);
    (Some(instr_vec), Some(txn_vec))
}

pub fn save_template(url: &Url, home_path: &PathBuf) -> PathBuf {
    let g_res = reqwest::blocking::get(&url.to_string());
    let g_path = home_path.join("template.json");
    let mut g_file = File::create(&g_path).expect("couldn't create file");
    let g_content = g_res.unwrap().bytes().unwrap().to_vec(); //.text().unwrap();
    g_file.write_all(g_content.as_slice()).unwrap();
    g_path
}

fn get_epoch_info(url: &Url) -> (Option<u64>, Option<Waypoint>) {
    let g_res = reqwest::blocking::get(&url.to_string());
    let string = g_res.unwrap().text().unwrap();
    let json: Value = string.parse().unwrap();
    let epoch = json
        .get("epoch")
        .unwrap()
        .as_u64()
        .expect("should have epoch number");
    let waypoint = json
        .get("waypoint")
        .unwrap()
        .as_str()
        .expect("should have epoch number");

    (Some(epoch), waypoint.parse().ok())
}

/// Creates an account.json file for the validator
fn write_manifest(
    path: &Option<PathBuf>,
    wallet: WalletLibrary,
    wizard_config: Option<AppCfg>,
    autopay_batch: Option<Vec<PayInstruction>>,
    autopay_signed: Option<Vec<SignedTransaction>>,
) {
    let cfg = if wizard_config.is_some() {
        wizard_config.unwrap()
    } else {
        app_config().clone()
    };

    let miner_home = path
        .clone()
        .unwrap_or_else(|| cfg.workspace.node_home.clone());

    let keys = KeyScheme::new(&wallet);
    let block = Block::parse_block_file(cfg.get_block_dir().join("block_0.json").to_owned());

    ValConfigs::new(
        block,
        keys,
        cfg.profile.ip.to_string(),
        autopay_batch,
        autopay_signed,
    )
    .create_manifest(miner_home);
}
 