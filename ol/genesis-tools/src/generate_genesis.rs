//! generate genesis files from snapshot

use anyhow::{Result, bail};
use libra_management::{
   error::Error
};


use libra_temppath::TempPath;
use libra_types::{
    access_path::AccessPath,
    account_address::AccountAddress,
    account_config::{
        coin1_tmp_tag, from_currency_code_string, BalanceResource, COIN1_NAME,
        AccountResource
    },
    account_state::AccountState,
    account_state_blob::AccountStateBlob,
    contract_event::ContractEvent,
    on_chain_config,
    on_chain_config::{config_address, ConfigurationResource, OnChainConfig, ValidatorSet},
    transaction::{
        ChangeSet, Transaction, WriteSetPayload
    },
    write_set::{WriteOp, WriteSetMut},
};
use executor::{
    db_bootstrapper::{generate_waypoint, maybe_bootstrap, get_balance},
};
use ol_fixtures::get_persona_mnem;
use storage_interface::DbReaderWriter;

use libra_vm::LibraVM;
use libradb::{LibraDB};
use std::{convert::TryFrom, fs::File, io::Write, io::Read};
use move_core_types::move_resource::MoveResource;
use ol_keys::{wallet::get_account_from_mnem};

/// wrapper for testing getting a genesis from a blob.
pub fn test_genesis_from_blob(account_state_blobs: &Vec<AccountStateBlob>, _db_rw: DbReaderWriter) -> Result<(), anyhow::Error> {
    let home = dirs::home_dir().unwrap();
    let genesis_path = home.join(".0L/genesis_from_snapshot.blob");

    let db_dir_tmp = TempPath::new();
    let (_db, db_rw) = DbReaderWriter::wrap(LibraDB::new_for_test(&db_dir_tmp));

    let mut file = File::open(genesis_path)
        .map_err(|e| Error::UnexpectedError(format!("Unable to open genesis file: {}", e)))?;
    let mut buffer = vec![];
    file.read_to_end(&mut buffer)
        .map_err(|e| Error::UnexpectedError(format!("Unable to read genesis: {}", e)))?;
    let genesis_txn = lcs::from_bytes(&buffer)
        .map_err(|e| Error::UnexpectedError(format!("Unable to parse genesis: {}", e)))?;

    let waypoint = generate_waypoint::<LibraVM>(&db_rw, &genesis_txn).unwrap();
    assert!(maybe_bootstrap::<LibraVM>(&db_rw, &genesis_txn, waypoint).unwrap());

    let mut index = 0;
    for blob in account_state_blobs {
        println!("index: {}", index);
        match get_account_details(blob) {
            Ok(details) => {
                if get_balance(&details.0, &db_rw) != details.1.coin() {
                    bail!("Balance not matching for blob index: {}", index);
                };
            },
            Err(e) => {
                println!("Warning on test: get_account_details at index {}: {}", index, e)
            }
        }
        index += 1;
    };
    Ok(())
}

fn get_configuration(db: &DbReaderWriter) -> ConfigurationResource {
    let config_blob = db
        .reader
        .get_latest_account_state(config_address())
        .unwrap()
        .unwrap();
    let config_state = AccountState::try_from(&config_blob).unwrap();
    config_state.get_configuration_resource().unwrap().unwrap()
}

/// Given a Genesis transaction, write a genesis.blob file
// TODO: A path needs to be given.
pub fn write_genesis_blob(genesis_txn: Transaction) -> Result<(), anyhow::Error> {
    let home = dirs::home_dir().unwrap();
    let ol_path = home.join(".0L/genesis_from_snapshot.blob");

    let mut file = File::create(ol_path).map_err(|e| {
        Error::UnexpectedError(format!("Unable to create genesis file: {}", e.to_string()))
    })?;
    let bytes = lcs::to_bytes(&genesis_txn).map_err(|e| {
        Error::UnexpectedError(format!("Unable to serialize genesis: {}", e.to_string()))
    })?;
    file.write_all(&bytes).map_err(|e| {
        Error::UnexpectedError(format!("Unable to write genesis file: {}", e.to_string()))
    })?;
    Ok(())
}

fn get_alice_authkey_for_swarm() -> Vec<u8> {
    let mnemonic_string = get_persona_mnem("alice");
    let account_details = get_account_from_mnem(mnemonic_string);
    account_details.0.to_vec()
}

/// take an unmodified account state and make into a writeset.
pub fn unmodified_state_into_writeset(account_state_blobs: &Vec<AccountStateBlob>) -> Result<WriteSetMut, anyhow::Error>  {
    let mut write_set_mut = WriteSetMut::new(vec![]);
    let mut index = 0;
    for blob in account_state_blobs {
        let account_state = AccountState::try_from(blob)
          .map_err(|e| Error::UnexpectedError(format!("Failed to parse blob: {}", e)))?;
        let address_option = account_state.get_account_address()?;
        match address_option {
            Some(address) => {
                for (k, v) in account_state.iter() {
                  // TODO: what is this checking?
                    if k == &AccountResource::resource_path() {
                        let item_tuple = (
                          AccessPath::new(address, k.clone()),
                          WriteOp::Value(v.clone()),
                        );

                        write_set_mut.push(item_tuple);
                    } else {
                        // TODO: why would this happen?
                        write_set_mut.push((
                            AccessPath::new(address, k.clone()),
                            WriteOp::Value(v.clone()),
                        ));
                    }
                }
                println!("process account index: {}", index);
            }, None => {
                println!("No address for error: {}", index);
            }
        }
        index += 1;
    }
    println!("Total accounts read: {}", index);
    Ok(write_set_mut)
}
/// Create a WriteSet from account state blobs
pub fn add_account_states_to_write_set(write_set_mut: &mut WriteSetMut, account_state_blobs: &Vec<AccountStateBlob>) -> Result<(), anyhow::Error> {
    let mut index = 0;
    let authentication_key = get_alice_authkey_for_swarm();
    for blob in account_state_blobs {
        let account_state = AccountState::try_from(blob)
          .map_err(|e| Error::UnexpectedError(format!("Failed to parse blob: {}", e)))?;
        let address_option = account_state.get_account_address()?;
        match address_option {
            Some(address) => {
                for (k, v) in account_state.iter() {
                    if k.clone() == AccountResource::resource_path() {
                        let account_resource_option = account_state.get_account_resource()?;
                        match account_resource_option {
                            Some(account_resource) => {
                                let account_resource_new = account_resource.clone_with_authentication_key(
                                    authentication_key.clone(), address.clone()
                                );
                                write_set_mut.push((
                                    AccessPath::new(address, k.clone()),
                                    WriteOp::Value(lcs::to_bytes(&account_resource_new).unwrap()),
                                ));
                            }, None => {
                                println!("Account resource not found for index: {}", index);
                            }
                        }
                    } else {
                        // TODO: why would this happen?
                        write_set_mut.push((
                            AccessPath::new(address, k.clone()),
                            WriteOp::Value(v.clone()),
                        ));
                    }
                }
                println!("process account index: {}", index);
            }, None => {
                println!("No address for error: {}", index);
            }
        }
        index += 1;
    }
    println!("Total accounts read: {}", index);
    Ok(())
}


/// given a vec of AccountStateBlobs, try to parse and bootsrap a database, and finally create a genesis.blob
pub fn generate_genesis_from_snapshot(account_state_blobs: &Vec<AccountStateBlob>, db: &DbReaderWriter) -> Result<Transaction, anyhow::Error> {
    let configuration = get_configuration(&db);
    let mut write_set_mut = WriteSetMut::new(vec![
        (
            ValidatorSet::CONFIG_ID.access_path(),
            WriteOp::Value(lcs::to_bytes(&ValidatorSet::new(vec![])).unwrap()),
        ),
        (
            AccessPath::new(config_address(), ConfigurationResource::resource_path()),
            WriteOp::Value(lcs::to_bytes(&configuration.bump_epoch_for_test()).unwrap()),
        )]
    );

    add_account_states_to_write_set(&mut write_set_mut, account_state_blobs)?;

    Ok(Transaction::GenesisTransaction(WriteSetPayload::Direct(ChangeSet::new(
        write_set_mut
        .freeze()?,
        vec![ContractEvent::new(
            on_chain_config::new_epoch_event_key(),
            0,
            coin1_tmp_tag(),
            vec![],
        )],
    ))))
}

/// Get account address and balance from AccountStateBlob
pub fn get_account_details(blob: &AccountStateBlob) -> Result<(AccountAddress, BalanceResource), anyhow::Error> {
    let account_state = AccountState::try_from(blob)
                                .map_err(|e| Error::UnexpectedError(format!("Failed to parse blob: {}", e)))?;
    let address_option = account_state.get_account_address()?;
    match address_option {
        Some(address) => {
            let balance_resource_map = account_state
            .get_balance_resources(&[from_currency_code_string(COIN1_NAME)?])?; 

            let balance_resource_option = balance_resource_map
                                    .get(&from_currency_code_string(COIN1_NAME)?);
            match balance_resource_option {
                Some(balance_resource) => {
                    Ok((address, BalanceResource::new(balance_resource.coin())))
                }, 
                None => {
                    bail!("Balance resource not found");
                }
            }
        }, 
        None => {
            bail!("Account address not found");
        }
    }
}
