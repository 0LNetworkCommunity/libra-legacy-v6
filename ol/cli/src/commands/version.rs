//! `version` subcommand

#![allow(clippy::never_loop)]

use crate::node::sync::get_local_height;

use super::OlCliCmd;
use abscissa_core::{Command, Options, Runnable};
use tokio::runtime::Runtime;


/// `version` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct VersionCmd {}

impl Runnable for VersionCmd {
    /// Print version message
    fn run(&self) {
        println!("{} {}", OlCliCmd::name(), OlCliCmd::version());
        // Create the runtime
        let mut rt = Runtime::new().unwrap();

        // Spawn a future onto the runtime
        match rt.block_on(get_local_height()){
            Ok(a) => {dbg!(a);},
            Err(e) => {dbg!(e);}
        };
        // get_local_height().await?;
    }
}
