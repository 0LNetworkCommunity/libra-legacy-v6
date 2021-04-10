//! `start`

use crate::prelude::*;
use crate::{
  backlog,
  block::*,
  entrypoint,
  submit_tx::{get_oper_params, get_params},
};
use crate::{config::MinerConfig, test_tx_swarm::get_params_from_swarm};
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};
use libra_genesis_tool::keyscheme::KeyScheme;

/// `start` subcommand
#[derive(Command, Debug, Options)]
pub struct StartCmd {
  // Option for --backlog, only sends backlogged transactions.
  #[options(
    short = "b",
    help = "Start but don't mine, and only resubmit backlog of proofs"
  )]
  backlog_only: bool,

  // don't process backlog
  #[options(short = "s", help = "Skip backlog")]
  skip_backlog: bool,

  // Option to us rpc url to connect
  #[options(
    short = "u",
    help = "Connect to upstream node, instead of default (local) node"
  )]
  upstream_url: bool,

  // Option for operator to submit transactions for owner.
  #[options(short = "o", help = "Operator will submit transactions for owner")]
  is_operator: bool,
}

impl Runnable for StartCmd {
  /// Start the application.
  fn run(&self) {
    let entry_args = entrypoint::get_args();
    let cfg = app_config().clone();

    let waypoint = match cfg.get_waypoint(entry_args.swarm_path.clone()) {
      Some(w) => w,
      _ => {
        println!("Waypoint: No waypoint found in key_store.json, 0L.toml, or in cli args");
        std::process::exit(-1);
      }
    };

    let tx_params = if self.is_operator {
      get_oper_params(waypoint, &cfg, entry_args.url, self.upstream_url)
    } else {
      if let Some(path) = entry_args.swarm_path {
        get_params_from_swarm(path, &entry_args.swarm_persona.expect("need to pass a `--persona` arg")).unwrap()
      } else {
        // prompt the owner for account
        let (_authkey, _account, wallet) = keygen::account_from_prompt();
        let keys = KeyScheme::new(&wallet);
        get_params(keys, waypoint, &cfg, entry_args.url, self.upstream_url)
      }
    };

    // Check for, and submit backlog proofs.
    if !self.skip_backlog {
      backlog::process_backlog(&cfg, &tx_params, self.is_operator);
    }

    if !self.backlog_only {
      // Steady state.
      let result = build_block::mine_and_submit(&cfg, tx_params, self.is_operator);
      match result {
        Ok(_val) => {}
        Err(err) => {
          println!("Failed to mine_and_submit: {}", err);
        }
      }
    }
  }
}

impl config::Override<MinerConfig> for StartCmd {
  // Process the given command line options, overriding settings from
  // a configuration file using explicit flags taken from command-line
  // arguments.
  fn override_config(&self, config: MinerConfig) -> Result<MinerConfig, FrameworkError> {
    Ok(config)
  }
}
