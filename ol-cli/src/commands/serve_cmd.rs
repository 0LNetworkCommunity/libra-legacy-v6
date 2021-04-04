//! `serve-cmd` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::server;


/// `serve-cmd` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct ServeCmd {}

impl Runnable for ServeCmd {
  /// Start the application.
  fn run(&self) {
    // abscissa_tokio::run(&APPLICATION, async {
    //   tokio::spawn(async move {
    //     println!("starting web-monitor");
    //     server::start_server()
    //   })
    // }).unwrap();
    server::start_server();
  }
}