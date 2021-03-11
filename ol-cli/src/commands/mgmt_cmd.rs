//! `mgmt` subcommand

use abscissa_core::{Command, Options, Runnable};
use crate::management;
/// `mgmt` subcommand
///
/// The `Options` proc macro generates an option parser based on the struct
/// definition, and is defined in the `gumdrop` crate. See their documentation
/// for a more comprehensive example:
///
/// <https://docs.rs/gumdrop/>
#[derive(Command, Debug, Options)]
pub struct MgmtCmd {
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

impl Runnable for MgmtCmd {
    /// Start the application.
    
    fn run(&self) {
        // management::fetch_backups().unwrap();

        management::start_fullnode();
    }
}
