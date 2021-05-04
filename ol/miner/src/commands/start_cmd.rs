//! `start`

use ol_types::config::AppCfg;
use crate::{backlog, block::*, entrypoint};
use crate::{entrypoint::EntryPointTxsCmd, prelude::*};
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};

use ol_types::config::TxType;
use reqwest::Url;
use txs::submit_tx::tx_params;

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
    #[options(help = "Connect to upstream node, instead of default (local) node")]
    upstream_url: bool,

    // Option to us rpc url to connect
    #[options(
        short = "u",
        help = "Connect to upstream node, instead of default (local) node"
    )]
    url: Option<Url>,

    // Option for operator to submit transactions for owner.
    #[options(short = "o", help = "Operator will submit transactions for owner")]
    is_operator: bool,
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
        let cfg = app_config().clone();

        let waypoint = if waypoint.is_none() {
            match cfg.get_waypoint(swarm_path.clone()) {
                Some(w) => Some(w),
                _ => {
                    status_err!("Cannot start without waypoint, exiting");
                    std::process::exit(-1);
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
            backlog::process_backlog(&cfg, &tx_params, self.is_operator);
        }

        if !self.backlog_only {
            // Steady state.
            let result = mine_and_submit(&cfg, tx_params, self.is_operator);
            match result {
                Ok(_val) => {}
                Err(err) => {
                    println!("Failed to mine_and_submit: {}", err);
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
