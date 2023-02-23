use anyhow::Result;
use diem_types::account_address::AccountAddress;
use std::{path::PathBuf, process::exit};
use ol_types::legacy_recovery::{save_recovery_file, read_from_recovery_file};
use gumdrop::Options;
use ol_genesis_tools::{
    compare,
    // swarm_genesis::make_swarm_genesis
    fork_genesis::{
        make_recovery_genesis_from_db_backup, make_recovery_genesis_from_vec_legacy_recovery,
    },
    process_snapshot::db_backup_into_recovery_struct,
};

#[tokio::main]
async fn main() -> Result<()> {
    #[derive(Debug, Options)]
    struct Args {
        #[options(help = "path to snapshot dir to read", short="v")]
        genesis_vals: Vec<AccountAddress>,

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
        export_json: Option<PathBuf>,

        #[options(help = "optional, get baseline genesis without changes, for debugging")]
        debug: bool,

        #[options(
            help = "optional, checks the --recovery-json-path state against the genesis in --output-path"
        )]
        check: bool,
    }

    let opts = Args::parse_args_default_or_exit();
    if opts.fork {
        // create a genesis.blob
        // there are two paths here
        // 1) do a new genesis straight from a db backup. Useful
        // for testing, debugging, and ci.
        // 2) use a JSON file with specific schma, which contains structured data for accounts.
        let output_path = opts
            .output_path
            .expect("ERROR: must provide output-path for genesis.blob, exiting.");

        if let Some(snapshot_path) = opts.snapshot_path {
            if !snapshot_path.exists() {
                panic!("ERROR: snapshot directory does not exist");
            }
            // Path 1 here.
            // here we are trying to do a rescue operation or
            // fork DIRECTLY from a DB backup.
            // This skips the step of creating an intermediary JSON file.
            // for more complex upgrades where names change, and state needs to
            // be migrated, this is risky and not ideal
            // you probably want a step where the data gets cleaned
            // and serialized to json for analysis.
            make_recovery_genesis_from_db_backup(
                output_path.clone(),
                snapshot_path,
                !opts.debug,
                opts.legacy,
                opts.genesis_vals
            )
            .await
            .expect("ERROR: could not create genesis from snapshot");
            Ok(())
        }
        // Path 2:
        // if we have a Recovery JSON file, let's use that.
        // this is useful when the upgrade has lots of breaking state
        // and is not backwards compatible.
        else if let Some(recovery_json_path) = opts.recovery_json_path {
            if !recovery_json_path.exists() {
                panic!("ERROR: recovery_json_path does not exist");
            }
            let recovery = read_from_recovery_file(&recovery_json_path);
            make_recovery_genesis_from_vec_legacy_recovery(
              &recovery,
              vec![],
              output_path, 
              opts.legacy
            )
                .expect("ERROR: failed to create genesis from recovery file");
            Ok(())
        } else {
            panic!("ERROR: must provide --snapshot-path or --recovery-json-path, exiting.");
        }
    } else if opts.output_path.is_some() && opts.recovery_json_path.is_some() && opts.check {
        let err_list = compare::compare_json_to_genesis_blob(
            opts.output_path.unwrap(),
            opts.recovery_json_path.unwrap(),
        )?;
        if !err_list.is_empty() {
            println!("ERROR: found errors:");

            err_list.into_iter().for_each(|ce| {
                println!(
                    "account: {:?}, msg: {}, balance_diff {}",
                    ce.account, ce.message, ce.bal_diff
                );
            });
        } else {
            println!("SUCCESS: no errors found");
        }
        Ok(())
    } else if let Some(json_destination_path) = opts.export_json {
        // just create recovery file
        let snapshot_path = opts
            .snapshot_path
            .expect("ERROR: must provide snapshot path, exiting.");
        if !snapshot_path.exists() {
            panic!("ERROR: --snapshot-path file does not exist");
        }
        let recovery_struct = db_backup_into_recovery_struct(&snapshot_path, false)
            .await
            .expect("could not export DB into JSON recovery file");

        save_recovery_file(&recovery_struct, &json_destination_path).unwrap_or_else(|_| panic!("ERROR: recovery data extracted, but failed to save file {:?}",
            &json_destination_path));

        Ok(())
    } else {
        println!("ERROR: no options provided, exiting.");
        exit(1);
    }
}
