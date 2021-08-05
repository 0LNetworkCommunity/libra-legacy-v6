use std::{path::PathBuf, process::exit};
use anyhow::Result;
use gumdrop::Options;
use ol_genesis_tools::read_archive::archive_into_recovery;

fn main() -> Result<()> {
    #[derive(Debug, Options)]
    struct Args {
        #[options(help = "what epoch to restore from archive")]
        epoch: Option<u64>,
        #[options(help = "path to snapshot dir to read")]
        snaphot_path: Option<PathBuf>,
        #[options(help = "swarm simulation mode")]
        swarm: bool,
        #[options(help = "write genesis from recovery file")]
        genesis: bool,
        #[options(help = "write recovery file from snapshot")]
        recover_path: Option<PathBuf>,
        #[options(help = "live fork mode")]
        live: bool,
        // #[options(help = "Url of the github repo with archive")]
        // epoch: Option<Url>,
    }

    let opts = Args::parse_args_default_or_exit();
    if opts.genesis {
        // create a genesis file from recovery file
        Ok(())
    } else if let Some(r_path) = opts.recover_path {
        // write recovery file
        if let Some(a_path) = opts.snaphot_path {
            archive_into_recovery(&a_path, &r_path);
        };
        Ok(())
    } else if opts.live {
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
        exit(1)
    }
}
