//! `version` subcommand

#![allow(clippy::never_loop)]
use abscissa_core::{Command, Options, Runnable};
use std::path::PathBuf;
use libradb::LibraDB;
use storage_interface::DbReader;
use libra_logger::info;
use lcs;

use libra_types::{
    account_address::AccountAddress, account_config::AccountResource, account_state::AccountState,
};
use std::convert::TryFrom;
use libra_types::transaction::TransactionPayload::WriteSet;
use regex::internal::Input;
use libra_types::access_path::AccessPath;
use move_core_types::language_storage::ResourceKey;
use move_core_types::move_resource::MoveResource;
use move_core_types::identifier::Identifier;
use crate::error::Error;

/// `export` subcommand
#[derive(Command, Debug, Default, Options)]
pub struct ExportCmd {
    #[options(help = "Provide a Libradb path for the libra chain")]
    db: PathBuf,

    #[options(help = "Path of output genesis.blob")]
    out: PathBuf,

    #[options(help = "Version of states to export")]
    version: u64,
}

impl Runnable for ExportCmd {
    /// Print version message
    fn run(&self) {
        println!("{} {}", self.db.to_str().unwrap(), self.out.to_str().unwrap());
        let ldb = LibraDB::open(&self.db.as_path(), true, None)
            .expect(&*format!("Could not open db from {}", &self.db.to_str().unwrap()));

        let version = if self.version > 0 {
            self.version
        }else{
             ldb.get_latest_version()
                .expect("Unable to get latest version")
        };

        println!("export states at version: {}", version);

        let backup = ldb.get_backup_handler();
        let iter = backup
            .get_account_iter(version)
            .expect("Unagle to get account iter");


        // prepare genesis context

        let mut num_account = 0;

        for res in iter {
            match res {
                Ok((_, blob)) => {
                    let account_state = AccountState::try_from(&blob).expect("Failed to read AccountState");

                    println!("{:?}", accs);
                    println!("==============");

                    for (key, value) in account_state.iter() {
                        //let _ap = key // hash of access_path.path;
                        //let value : Option<AccountResource> = lcs::from_bytes(value).unwrap(); // we need specify a return type to T, which is depend on access_type.
                        println!("{:?}: {:?}", key, value);
                    }

                    // let ass = accs.get_account_resource().unwrap().unwrap();
                    // ass.resource_path();

                    let addr = accs
                        .get_account_address()
                        .expect("Could not get address from state");

                    match addr {
                        Some(x) => {
                            num_account += 1;
                            println!("Address: {:?}", x);
                        }
                        None => println!("Skipping: No address for  AccountState: {:?}", accs),
                    }
                }
                Err(x) => println!("Got err iterating through AccountStateBlobs {:?}", x),
            }
        }
        info!("Total Accounts: {}", num_account);
    }
}
