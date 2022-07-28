use anyhow::Result;
use std::{path::PathBuf, process::exit};

use gumdrop::Options;
use ol_genesis_tools::{fork_genesis::make_recovery_genesis, swarm_genesis::make_swarm_genesis};

#[tokio::main]
async fn main() -> Result<()> {
    #[derive(Debug, Options)]
    struct Args {
        #[options(help = "what epoch to restore from archive")]
        epoch: Option<u64>,
        #[options(help = "path to snapshot dir to read")]
        snapshot_path: Option<PathBuf>,
        #[options(help = "write genesis from snapshot")]
        output_path: Option<PathBuf>,
        #[options(help = "create a genesis for a fork")]
        fork: bool,
        #[options(help = "create a genesis from Libra legacy")]
        legacy: bool,
        #[options(help = "optional, write recovery file from snapshot")]
        recover: Option<PathBuf>,
        #[options(help = "optional, get baseline genesis without changes, for dubugging")]
        debug_baseline: bool,
        #[options(help = "live fork mode")]
        daemon: bool,
        #[options(help = "swarm simulation mode")]
        swarm: bool,
    }

    let opts = Args::parse_args_default_or_exit();
    if opts.fork {
        if let Some(g_path) = opts.output_path {
            if let Some(s_path) = opts.snapshot_path {
                if !s_path.exists() {
                    println!("ERROR: snapshot directory does not exist: {:?}", &s_path);
                    exit(1);
                }
                // create a genesis file from archive file
                match make_recovery_genesis(g_path, s_path, !opts.debug_baseline, opts.legacy).await
                {
                    Ok(_) => return Ok(()),
                    Err(e) => {
                        println!(
                            "ERROR: could not create genesis from snapshot, message: {:?}",
                            e
                        );
                        exit(1);
                    }
                };
            } else {
                println!("ERROR: must provide a path with --snapshot, exiting.");
                exit(1);
            }
        }
        println!("ERROR: must provide --output-path for genesis.blob, exiting.");
        exit(1);
    } else if let Some(_a_path) = opts.recover {
        // just create recovery file

        return Ok(());
    } else if opts.daemon {
        // start the live fork daemon

        return Ok(());
    } else if opts.swarm {
        // Write swarm genesis from snapshot, for CI and simulation
        if let Some(s_path) = opts.snapshot_path {
            if !s_path.exists() {
                println!("ERROR: snapshot directory does not exist: {:?}", &s_path);
                exit(1);
            }
            make_swarm_genesis(opts.output_path.unwrap(), s_path).await?;
            return Ok(());
        } else {
            println!("ERROR: must provide a path with --snapshot, exiting.");
            exit(1);
        }
    } else {
        println!("ERROR: no options provided, exiting.");
        exit(1);
    }
}
