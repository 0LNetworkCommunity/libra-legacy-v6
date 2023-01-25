use anyhow::Result;
use std::{path::PathBuf, process::exit};

use gumdrop::Options;
use ol_genesis_tools::{
    fork_genesis::{
        make_recovery_genesis_from_archive,
        make_recovery_genesis_from_recovery
    },
    process_snapshot::archive_into_recovery,
    recover::save_recovery_file,
    recover::read_from_recovery_file,
    swarm_genesis::make_swarm_genesis
};

#[tokio::main]
async fn main() -> Result<()> {
    #[derive(Debug, Options)]
    struct Args {
        #[options(help = "what epoch to restore from archive")]
        epoch: Option<u64>,

        #[options(help = "path to snapshot dir to read")]
        snapshot_path: Option<PathBuf>,

        #[options(help = "path to recovery JSON dir to read")]
        recovery_json_path: Option<PathBuf>,        

        #[options(help = "write genesis from snapshot")]
        output_path: Option<PathBuf>,

        #[options(help = "create a genesis for a fork")]
        fork: bool,

        #[options(help = "create a genesis from Libra legacy")]
        legacy: bool,

        #[options(help = "optional, write recovery file from snapshot")]
        recover: Option<PathBuf>,

        #[options(help = "optional, get baseline genesis without changes, for debugging")]
        debug_baseline: bool,

        #[options(help = "live fork mode")]
        daemon: bool,
        
        #[options(help = "swarm simulation mode")]
        swarm: bool,
    }

    let opts = Args::parse_args_default_or_exit();
    if opts.fork {
        let output_path = opts.output_path
            .expect("ERROR: must provide output-path for genesis.blob, exiting.");

        if let Some(snapshot_path) = opts.snapshot_path {
            if !snapshot_path.exists() {
                panic!("ERROR: snapshot directory does not exist");
            }
            // create a genesis file from archive file
            make_recovery_genesis_from_archive(
                output_path.clone(), snapshot_path, !opts.debug_baseline, opts.legacy
            ).await.expect("ERROR: could not create genesis from snapshot");
            return Ok(());
        }
        else if let Some(recovery_json_path) = opts.recovery_json_path {
            if !recovery_json_path.exists() {
                panic!("ERROR: recovery_json_path does not exist");
            }            
            let recovery = read_from_recovery_file(&recovery_json_path);
            make_recovery_genesis_from_recovery(
                recovery, output_path, opts.legacy
            ).expect("ERROR: failed to create genesis from recovery file");
            return Ok(());
        }
        else {
            panic!("ERROR: must provide --snapshot-path or --recovery-json-path, exiting.");
        }
    } else if let Some(recovery_path) = opts.recover {
        // just create recovery file
        let snapshot_path = opts.snapshot_path
            .expect("ERROR: must provide snapshot path, exiting.");
        if !snapshot_path.exists() {
            panic!("ERROR: snapshot_path does not exist");
        }
        let recovery = archive_into_recovery(&snapshot_path, false).await.unwrap();
        save_recovery_file(&recovery, &recovery_path)
            .expect("ERROR: failed to create recovery from snapshot,");

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
