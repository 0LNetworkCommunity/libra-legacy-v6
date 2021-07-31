//! `start`

use std::process::exit;

use ol_types::config::AppCfg;
use crate::{backlog, block::*, entrypoint};
use crate::{entrypoint::EntryPointTxsCmd, prelude::*};
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};

use ol_types::config::TxType;
use reqwest::Url;
use txs::submit_tx::tx_params;

/// `start` subcommand
#[derive(Command, Default, Debug, Options)]
pub struct StartCmd {
    /// Option for --backlog, only sends backlogged transactions.
    #[options(
        short = "b",
        help = "Start but don't mine, and only resubmit backlog of proofs"
    )]
    backlog_only: bool,

    /// don't process backlog
    #[options(short = "s", help = "Skip backlog")]
    skip_backlog: bool,

    /// Option to us rpc url to connect
    #[options(help = "Connect to upstream node, instead of default (local) node")]
    upstream_url: bool,

    /// Option to us rpc url to connect
    #[options(
        short = "u",
        help = "Connect to upstream node, instead of default (local) node"
    )]
    url: Option<Url>,
}

impl Runnable for StartCmd {
    /// Start the application.
    fn run(&self) {
        let EntryPointTxsCmd {
            url,
            waypoint,
            swarm_path,
            swarm_persona,
            is_operator,
            use_upstream_url,
            ..
        } = entrypoint::get_args();
        
        // config reading respects swarm setup
        // so also cfg.get_waypoint will return correct data
        let cfg = app_config().clone();

        let waypoint = if waypoint.is_none() {
            match cfg.get_waypoint(None) {
                Ok(w) => Some(w),
                Err(e) => {
                    status_err!("Cannot start without waypoint. Message: {:?}", e);
                    exit(-1);
                }
            }
        } else { waypoint };

        let tx_params = tx_params(
            cfg.clone(),
            url,
            waypoint,
            swarm_path,
            swarm_persona,
            TxType::Miner,
            is_operator,
            use_upstream_url,
        ).expect("could not get tx parameters");

        // Check for, and submit backlog proofs.
        if !self.skip_backlog {
          // TODO: remove is_operator from signature, since tx_params has it.
            match backlog::process_backlog(&cfg, &tx_params, is_operator) {
                Ok(()) => status_ok!("Backlog:", "backlog committed to chain"),
                Err(e) => {
                    println!("WARN: Failed fetching remote state: {}", e);
                }
            }
        }

        println!("url: {}", tx_params.url.clone());
        
        if !self.backlog_only {
            // Steady state.
            let result = mine_and_submit(&cfg, tx_params, is_operator);
            match result {
                Ok(_val) => {}
                Err(err) => {
                    println!("ERROR: miner failed, message: {:?}", err);
                    // exit on unrecoverable error.
                    exit(1);

                }
            }
        }
    }
}

impl config::Override<AppCfg> for StartCmd {
    // Process the given command line options, overriding settings from
    // a configuration file using explicit flags taken from command-line
    // arguments.
    fn override_config(&self, config: AppCfg) -> Result<AppCfg, FrameworkError> {
        Ok(config)
    }
}
