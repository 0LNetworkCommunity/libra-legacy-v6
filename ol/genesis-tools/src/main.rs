use std::{path::PathBuf, process::exit};
use anyhow::Result;

use gumdrop::Options;


fn main() -> Result<()> {
    #[derive(Debug, Options)]
    struct Args {
        #[options(help = "what epoch to restore from archive")]
        epoch: Option<u64>,
        #[options(help = "path to snapshot dir to read")]
        snaphot_path: Option<PathBuf>,
        #[options(help = "write genesis from recovery file")]
        genesis: bool,
        #[options(help = "write recovery file from snapshot")]
        recover_path: Option<PathBuf>,
        #[options(help = "live fork mode")]
        daemon: bool,
        #[options(help = "swarm simulation mode")]
        swarm: bool,
    }

    let opts = Args::parse_args_default_or_exit();
    if opts.genesis {
        // create a genesis file from recovery file
        Ok(())
    } else if let Some(_a_path) = opts.snaphot_path {

        
        Ok(())
    } else if opts.daemon {
        // start the live fork daemon

        Ok(())
    } else if opts.swarm {
        // Write swarm genesis from snapshot, for CI and simulation
        if let Some(_archive_path) = opts.snaphot_path {
            // TODO: block on this future
            // archive_into_writeset(archive_path);
        }
        Ok(())
    } else {
        println!("No options provided, exiting.");
        exit(1);
    }
}
