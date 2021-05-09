//! `pilot` subcommand

#![allow(clippy::never_loop)]
use super::OlCliCmd;
use crate::{
  pilot,
    entrypoint,
    node::client,
    node::node::Node,
    prelude::app_config,
};
use abscissa_core::{Command, Options, Runnable};

/// `pilot` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct PilotCmd {}

impl Runnable for PilotCmd {
    /// Print version message
    fn run(&self) {
        println!("PILOT - {}", OlCliCmd::version());
        let args = entrypoint::get_args();
        let verbose = true;
        let mut cfg = app_config().clone();
        let (client, wp) = client::pick_client(args.swarm_path.clone(), &cfg)
            .expect("could not create connect a client");
        if args.swarm_path.is_some() {
            let mut tp = args.swarm_path.unwrap();
            tp.push("0");
            cfg.workspace.node_home = tp;
        }
        let mut node = Node::new(client, cfg.clone());
        pilot::maybe_restore_db(&mut node, verbose);

        loop {
            pilot::run_once(&mut node, wp, verbose);
        }
    }
}
