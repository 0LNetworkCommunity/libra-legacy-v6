mod wizard;

use anyhow::Result;
use diem_secure_storage::{GitHubStorage, Storage};
use vm_genesis::{TestValidator, Validator};
use std::{path::PathBuf, process::exit, time::Duration, thread};
use ol_types::{legacy_recovery::{save_recovery_file, read_from_recovery_file}, OLProgress};
use gumdrop::Options;
use diem_genesis_tool::genesis::Genesis;
use ol_genesis_tools::{
    compare,
    // swarm_genesis::make_swarm_genesis
    fork_genesis::{
        make_recovery_genesis_from_db_backup, make_recovery_genesis_from_vec_legacy_recovery,
    },
    process_snapshot::db_backup_into_recovery_struct,
};
use indicatif::ProgressIterator;

// #[tokio::main]
fn main() -> Result<()> {
    #[derive(Debug, Options)]
    struct Args {
        #[options(help = "use wizard")]
        wizard: bool,

        #[options(short="o", help = "org of remote github repo for genesis coordination")]
        genesis_repo_owner: Option<String>,

        #[options(short="n", help = "name of remote github repo for genesis coordination")]
        genesis_repo_name: Option<String>,

        #[options(help = "github token as string for github")]
        genesis_gh_token: Option<String>,

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

    if opts.wizard && 
      opts.genesis_repo_owner.is_some() && 
      opts.genesis_repo_name.is_some() 
    {
      let mut w = wizard::GenesisWizard::default();
      w.repo_name = opts.genesis_repo_name.as_ref().unwrap().clone();
      w.repo_owner = opts.genesis_repo_owner.as_ref().unwrap().clone();
      w.start_wizard()?
    }

    let rt = tokio::runtime::Runtime::new().unwrap();

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

            let genesis_vals: Vec<Validator> = if 
            opts.genesis_repo_owner.is_some() &&
            opts.genesis_repo_name.is_some() {
              
              // NOTE: this is a real PITA.
              // There are two structs called SecureBackend, and we need to do some gymnastics. Plus they wrote their own parser for the cli args. Sigh.
              // let b =  diem_management::secure_backend::storage(&s).unwrap();

              

              let gh_config = GitHubStorage::new(
                opts.genesis_repo_owner.unwrap(),
                opts.genesis_repo_name.unwrap(),
                "master".to_string(),
                opts.genesis_gh_token.unwrap_or("{}".to_string()),
              );
              let b = Storage::GitHubStorage(gh_config);

              Genesis::just_the_vals(b).expect("could not get the validator set")
            } else {
              // TODO: this is duplicated in tests
              TestValidator::new_test_set(Some(4)).into_iter()
              .map(|v| {v.data}).collect()
              // create testnet genesis

            };
            
            rt.block_on({
              make_recovery_genesis_from_db_backup(
                output_path.clone(),
                snapshot_path,
                !opts.debug,
                opts.legacy,
                &genesis_vals
                // opts.genesis_vals
            )
          })?;
            // make_recovery_genesis_from_db_backup(
            //     output_path.clone(),
            //     snapshot_path,
            //     !opts.debug,
            //     opts.legacy,
            //     &genesis_vals
            //     // opts.genesis_vals
            // )
            // // .await
            // .expect("ERROR: could not create genesis from snapshot");
            carpe_diem();
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
              &vec![],
              output_path, 
              opts.legacy
            )
                .expect("ERROR: failed to create genesis from recovery file");
            carpe_diem();
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

        let recovery_struct = rt.block_on({
          db_backup_into_recovery_struct(&snapshot_path)
        })?;

        save_recovery_file(&recovery_struct, &json_destination_path).unwrap_or_else(|_| panic!("ERROR: recovery data extracted, but failed to save file {:?}",
            &json_destination_path));

        Ok(())
    } else {
        println!("ERROR: no options provided, exiting.");
        exit(1);
    }
}


fn carpe_diem() {
    // be happy
    (0..20).progress_with_style(OLProgress::fun())
    .for_each(|_|{
      thread::sleep(Duration::from_millis(300));
    });
}