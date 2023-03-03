use anyhow::Result;


use std::{path::PathBuf, process::exit};
use ol_types::{legacy_recovery::{save_recovery_file, read_from_recovery_file}};
use gumdrop::Options;

use ol_genesis_tools::{
    compare,
    // swarm_genesis::make_swarm_genesis
    fork_genesis::{
        make_recovery_genesis_from_vec_legacy_recovery,
    },
    process_snapshot::db_backup_into_recovery_struct, wizard, run::default_run,
};



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

        #[options(help = "epoch to restore to")]
        genesis_restore_epoch: Option<u64>,

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
      w.epoch = opts.genesis_restore_epoch;
      w.start_wizard()?;
      return Ok(()); // exit
    }


    if opts.fork {
        if opts.snapshot_path.is_some() {
          default_run(
            opts.output_path.unwrap(),
            opts.snapshot_path.unwrap(),
            opts.genesis_repo_owner.unwrap(),
            opts.genesis_repo_name.unwrap(),
            opts.genesis_gh_token.unwrap(),
            opts.debug,
          )?;

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
              opts.output_path.unwrap(), 
              opts.debug
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

        let rt = tokio::runtime::Runtime::new().unwrap();
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
