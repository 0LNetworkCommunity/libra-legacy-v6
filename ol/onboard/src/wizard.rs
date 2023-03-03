//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::commands::genesis_files_cmd::fetch_genesis_files_from_repo;
use diem_genesis_tool::ol_node_files;
use diem_types::chain_id::NamedChain;
use diem_types::{transaction::SignedTransaction, waypoint::Waypoint};
use diem_wallet::WalletLibrary;
use ol::{commands::init_cmd, config::AppCfg};
use ol_keys::{scheme::KeyScheme, wallet};
use ol_types::config::{bootstrap_waypoint_from_upstream, IS_TEST};
use ol_types::{fixtures, OLProgress};
use ol_types::{account::ValConfigs, config::TxType, pay_instruction::PayInstruction};
use reqwest::Url;
use std::fs;
use std::process::exit;
use std::{fs::File, io::Write, path::PathBuf};
use txs::commands::autopay_batch_cmd;
use txs::tx_params::TxParams;

/// `validator wizard` subcommand
#[derive(Clone, Debug, Default)]
// TODO: should end users also use this struct?
pub struct OnboardWizard {
    /// where to output the account.json, genesis, 0L, etc files, defaults to node home
    pub output_path: Option<PathBuf>,
    /// explicitly set home path instead of answer in wizard, for CI usually
    pub home_path: Option<PathBuf>,
    /// id of the chain
    pub chain_id: Option<NamedChain>,
    /// github org of genesis repo
    pub github_org: Option<String>,
    /// repo with with genesis transactions
    pub repo: Option<String>,
    /// use a genesis file instead of building
    pub prebuilt_genesis: Option<PathBuf>,
    /// fetching genesis blob from github
    pub fetch_git_genesis: bool,
    /// skip mining a block zero
    pub skip_mining: bool,
    /// template account.json to configure from
    pub template_url: Option<Url>,
    /// autopay file if instructions are to be sent
    pub autopay_file: Option<PathBuf>,
    /// An upstream peer to use in 0L.toml
    pub upstream_peer: Option<Url>,
    /// If validator is building from source
    pub source_path: Option<PathBuf>,
    /// Explicitly set the waypoint
    pub waypoint: Option<Waypoint>,
    /// Explicitly set the epoch
    pub epoch: Option<u64>,
    /// For testing in ci, use genesis.blob fixtures
    pub ci: bool,
    /// Used only on genesis ceremony
    pub genesis_ceremony: bool,
}

impl OnboardWizard {
    /// starts the onboarding wizard from parameters above.
    pub fn run(&self) -> anyhow::Result<AppCfg>{
        // Note. `onboard` command DOES NOT READ CONFIGS FROM 0L.toml

        println!(
            "\nValidator Config Wizard.\nNext you'll enter your mnemonic and some other info to configure your validator node and on-chain account. If you haven't yet generated keys, run the standalone keygen tool with 'onboard keygen'."
        );

        // if !self.skip_mining {
        //     println!("\nYour first 0L proof-of-work will also be mined now. Expect this take at least 30 minutes on modern CPUs.\n");
        // }

        // let entry_args = entrypoint::get_args();

        // Get credentials from prompt
        let (authkey, account, wallet) = wallet::get_account_from_prompt();

        let (epoch, waypoint) = if self.epoch.is_none() && self.waypoint.is_none() {
            if let Some(mut u) = self.template_url.clone() {
                println!("attempting to bootstap current waypoint and epoch from --template-url");
                match bootstrap_waypoint_from_upstream(&mut u) {
                    Ok((e, w)) => (Some(e), Some(w)),
                    Err(_) => {
                        println!("No epoch or waypoint found from template URL, continuing without setting. Otherwise explicitly set --epoch and --waypoint");
                        (self.epoch, self.waypoint)
                    }
                }
            } else {
                (self.epoch, self.waypoint)
            }
        } else {
            (self.epoch, self.waypoint)
        };

        let rpc_node = self
            .upstream_peer
            .clone()
            .unwrap_or(Url::parse("http://localhost:8080").unwrap());

        let app_config = AppCfg::init_app_configs(
            authkey,
            account,
            &Some(rpc_node),
            &self.home_path,
            &epoch,
            &waypoint,
            &self.source_path,
            None,
            None,
            &self.chain_id,
        )
        .unwrap_or_else(|e| {
            println!("could not create app configs, exiting. Message: {:?}", &e);
            exit(1);
        });

        let base_waypoint = app_config.chain_info.base_waypoint.clone();


        // Initialize Validator Keys
        // this also sets a genesis waypoint if one was provide, e.g. from an upstream peer.
        init_cmd::initialize_val_key_store(
            &wallet,
            &app_config,
            base_waypoint,
            *&self.genesis_ceremony,
        )
        .unwrap_or_else(|e| {
            println!(
                "could not initialize validator key_store.json, exiting. Message: {:?}",
                &e
            );
            exit(1);
        });

        // OLProgress::complete("Key file written [key_store.json]");

        // Retrieve the genesis block and build a number of node configuration files. Note: In genesis all node files are created through multiple steps in config/management/genesis, this should be skipped
        if !self.genesis_ceremony {
            self.get_genesis_and_make_node_files(&app_config);
        }

        // V6: Mining is not necessary for onboarding.

        // if !self.skip_mining {
        //     // Mine Proof
        //     match tower::proof::write_genesis(&app_config) {
        //         Ok(_) => {
        //             status_ok!(
        //                 "\nGenesis proof complete",
        //                 "\n...........................\n"
        //             );
        //         }
        //         Err(e) => {
        //             println!(
        //                 "ERROR: could not write genesis tower proof, message: {:?}",
        //                 &e.to_string()
        //             )
        //         }
        //     };
        // }

        // Write account manifest
        write_account_json(
            &self.output_path,
            wallet,
            Some(app_config.clone()),
            None,
            None,
        );
        
        OLProgress::complete("Success, your validator is ready to go!");


        if !self.genesis_ceremony {
            println!(
                "\nStart a web server with basic info using `ol start`. \nThen ask another validator to onboard you by referencing this server `txs create-validator -u http://{}`",
                &app_config.profile.ip
            );
        }
        Ok(app_config)
    }

  fn get_genesis_and_make_node_files(
      &self,
      cfg: &AppCfg,
  ) {
      // The default behavior is to fetch the genesis from a github repo.
      // if this is not possible then the user should have set a prebuilt genesis path.

      // in case of CI copy
      let genesis_blob_path = if self.ci && self.home_path.is_some() {
          let home_path = self.home_path.clone().unwrap();
          fs::copy(
              fixtures::get_test_genesis_blob().as_os_str(),
              home_path.join("genesis.blob"),
          )
          .unwrap_or_else(|e| {
              println!(
                  "could not copy test fixture genesis.blob file, exiting. Message: {:?}",
                  &e
              );
              exit(1);
          });

          // make file fixture
          fs::write(
              home_path.join("genesis_waypoint.txt"),
              "0:683185844ef67e5c8eeaa158e635de2a4c574ce7bbb7f41f787d38db2d623ae2",
          )
          .expect("could not write genesis_waypoint.txt");

          println!("WARN: using test genesis.blob");

          Some(home_path.join("genesis.blob"))
      } else if self.prebuilt_genesis.is_some() {
          // user can override with a prebuilt genesis locally.
          self.prebuilt_genesis.clone()
          // Some(p.to_owned())
      } else {
          // default behavior: fetching the genesis files from genesis-archive, unless overrideen
          match fetch_genesis_files_from_repo(
              cfg.workspace.node_home.clone(),
              &self.github_org,
              &self.repo,
          ) {
              Ok(path) => {
                  Some(path)
              }
              Err(_) => {
                  println!("ERROR: could not get a genesis.blob from Github repo. You can override this behavior with --prebuilt-genesis <path/to/genesis.blob>. Exiting");
                  exit(1);
              }
          }
      };

      let home_dir = cfg.workspace.node_home.to_owned();
      // 0L convention is for the namespace of the operator to be appended by '-oper'
      let val_ip_address = cfg.profile.ip;
      // this needs to be the same namespace as in initialize_validator
      let namespace = cfg.profile.account.to_hex() + "-oper";

      // TODO: use node_config to get the seed peers and then write upstream_node vec in 0L.toml from that.
      match ol_node_files::onboard_helper_all_files(
          home_dir.clone(),
          self.chain_id.unwrap_or(NamedChain::MAINNET),
          self.github_org.clone(),
          self.repo.clone(),
          &namespace,
          &genesis_blob_path,
          &false,
          None,
          &None,
          Some(val_ip_address),
      ) {
          Ok(_) => {}
          Err(e) => {
              println!("Cannot create validator, exiting. Messsage: {:?}", &e);
              exit(1);
          }
      };
  }

}

/// get autopay instructions from file
pub fn get_autopay_batch(
    template: &Option<Url>,
    file_path: &Option<PathBuf>,
    home_path: &PathBuf,
    cfg: &AppCfg,
    wallet: &WalletLibrary,
    is_swarm: bool,
    is_genesis: bool,
) -> (Option<Vec<PayInstruction>>, Option<Vec<SignedTransaction>>) {
    let file_name = if template.is_some() {
        // assumes the template was downloaded from URL
        "template.json"
    } else {
        "autopay_batch.json"
    };

    let starting_epoch = cfg.chain_info.base_epoch.unwrap_or(0);
    let instr_vec = PayInstruction::parse_autopay_instructions(
        &file_path.clone().unwrap_or(home_path.join(file_name)),
        Some(starting_epoch.clone()),
        None,
    )
    .unwrap_or_else(|e| {
        println!(
            "could not parse autopay instructions, exiting. Message: {:?}",
            &e
        );
        exit(1);
    });

    if is_genesis {
        return (Some(instr_vec), None);
    }

    let script_vec = autopay_batch_cmd::process_instructions(instr_vec.clone());
    let mut tx_params = TxParams::get_tx_params_from_toml(
        cfg.to_owned(),
        TxType::Miner,
        Some(wallet),
        "http://0.0.0.0".parse().unwrap(), // this doesn't matter for onboarding autopay signatures.
        None,
        is_swarm,
    )
    .unwrap_or_else(|e| {
        println!(
            "could not get tx params from 0L.toml, exiting. Message: {:?}",
            &e
        );
        exit(1);
    });

    let tx_expiration_sec = if *IS_TEST {
        // creating fixtures here, so give it near infinite expiry
        100 * 360 * 24 * 60 * 60
    } else {
        // give the tx a very long expiration, 7 days.
        7 * 24 * 60 * 60
    };
    tx_params.tx_cost.user_tx_timeout = tx_expiration_sec;
    let txn_vec = autopay_batch_cmd::sign_instructions(script_vec, 0, &tx_params);
    (Some(instr_vec), Some(txn_vec))
}

/// save template file
pub fn save_template(url: &Url, home_path: &PathBuf) -> PathBuf {
    let g_res = reqwest::blocking::get(&url.to_string());
    let g_path = home_path.join("template.json");
    let mut g_file = File::create(&g_path).unwrap_or_else(|e| {
        println!("couldn't create file, exiting. Message: {:?}", &e);
        exit(1);
    });

    let g_content = g_res
        .unwrap_or_else(|e| {
            println!(
                "could not parse http request to peer, exiting. Message: {:?}",
                &e
            );
            exit(1);
        })
        .bytes()
        .unwrap_or_else(|e| {
            println!(
                "cannot connect to upstream node, exiting. Message: {:?}",
                &e
            );
            exit(1);
        })
        .to_vec();
    g_file.write_all(g_content.as_slice()).unwrap_or_else(|e| {
        println!("could not write files, exiting. Message: {:?}", &e);
        exit(1);
    });

    g_path
}

/// Creates an account.json file for the validator
pub fn write_account_json(
    json_path: &Option<PathBuf>,
    wallet: WalletLibrary,
    wizard_config: Option<AppCfg>,
    autopay_batch: Option<Vec<PayInstruction>>,
    autopay_signed: Option<Vec<SignedTransaction>>,
){
    let cfg = wizard_config.unwrap_or(AppCfg::default());
    let json_path = json_path.clone().unwrap_or(cfg.workspace.node_home.clone());
    let keys = KeyScheme::new(&wallet);
    // let block = VDFProof::parse_block_file(cfg.get_block_dir().join("proof_0.json").to_owned()).ok();

    match ValConfigs::new(
        None,
        keys,
        cfg.profile.ip,
        cfg.profile.vfn_ip.unwrap_or("0.0.0.0".parse().unwrap()),
        autopay_batch,
        autopay_signed,
    )
    .create_manifest(json_path)
    {
        Ok(_) => {}
        Err(e) => {
            println!(
                "ERROR: could not write account manifest, message: {:?}",
                &e.to_string()
            );
        }
    }
}

