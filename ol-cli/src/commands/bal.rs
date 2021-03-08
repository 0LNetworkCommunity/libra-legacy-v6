//! `bal` subcommand

use abscissa_core::{Command, Options, Runnable};
use cli::client_proxy::ClientProxy;

/// `bal` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct BalCmd {
    // Example `--foobar` (with short `-f` argument)
    // #[options(short = "f", help = "foobar path"]
    // foobar: Option<PathBuf>

    // Example `--baz` argument with no short version
    // #[options(no_short, help = "baz path")]
    // baz: Options<PathBuf>

    // "free" arguments don't have an associated flag
    // #[options(free)]
    // free_args: Vec<String>,
}

impl Runnable for BalCmd {
    /// Start the application.
    fn run(&self) {
        // let mut client_proxy = ClientProxy::new(
        //     1,
        //     &args.url,
        //     &faucet_account_file,
        //     &treasury_compliance_account_file,
        //     &dd_account_file,
        //     true, // 0L change
        //     args.faucet_url.clone(),
        //     mnemonic_file,
        //     Some(mnemonic_string.unwrap().trim().to_owned()), // 0L change
        //     waypoint,
        // )
        // .expect("Failed to construct client.");

        // Your code goes here
    }
}
