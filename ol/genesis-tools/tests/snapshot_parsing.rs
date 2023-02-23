mod support;

use diem_types::account_state::AccountState;
use diem_types::ol_miner_state::TowerStateResource;
use diem_types::{account_config::BalanceResource, validator_config::ValidatorConfigResource};
use move_core_types::move_resource::MoveResource;
use ol_genesis_tools::{
  read_snapshot::read_from_snaphot_manifest,
  process_snapshot::accounts_from_snapshot_backup,

};
use ol_types::legacy_recovery::accounts_into_recovery;
use support::path_utils::snapshot_path;
use std::convert::TryFrom;

#[test]

pub fn test_accounts_into_recovery() {
    let path = snapshot_path();
    let path_man = path.join("state.manifest");

    // let path_man = buf.clone().join("state.manifest");
    println!("Running.....");
    let backup = read_from_snaphot_manifest(&path_man).unwrap();

    let account_blobs_futures = accounts_from_snapshot_backup(backup, &path);
    let account_blobs = tokio_test::block_on(account_blobs_futures).unwrap();
    let genesis_recovery_list = accounts_into_recovery(&account_blobs).unwrap();
    println!(
        "Total GenesisRecovery objects: {}",
        &genesis_recovery_list.len()
    );
    for blob in account_blobs {
        let account_state = AccountState::try_from(&blob).unwrap();
        if let Some(address) = account_state.get_account_address().unwrap() {
            let mut address_processed = false;
            for gr in &genesis_recovery_list {
                if gr.account != Some(address) {
                    continue;
                }
                // iterate over all the account's resources\
                for (k, v) in account_state.iter() {
                    // extract the validator config resource
                    if k.clone() == BalanceResource::resource_path() {
                        match &gr.balance {
                            Some(balance) => {
                                if bcs::to_bytes(&balance).unwrap() != v.clone() {
                                    panic!("Balance resource not found in GenesisRecovery object: {:?}", gr.account);
                                }
                            }
                            None => {
                                panic!("Balance not found");
                            }
                        }
                    }
                    if k.clone() == ValidatorConfigResource::resource_path() {
                        match &gr.val_cfg {
                            Some(val_cfg) => {
                                if bcs::to_bytes(&val_cfg).unwrap() != v.clone() {
                                    panic!("ValidatorConfigResource not found in GenesisRecovery object: {:?}", gr.account);
                                }
                            }
                            None => {
                                panic!("ValidatorConfigResource not found");
                            }
                        }
                    }
                    if k.clone() == TowerStateResource::resource_path() {
                        match &gr.miner_state {
                            Some(miner_state) => {
                                if bcs::to_bytes(&miner_state).unwrap() != v.clone() {
                                    panic!("TowerStateResource not found in GenesisRecovery object: {:?}", gr.account);
                                }
                            }
                            None => {
                                panic!("TowerStateResource not found");
                            }
                        }
                    }
                }
                println!("processed account: {:?}", address);
                address_processed = true;
                break;
            }
            if !address_processed {
                panic!("Address not found for {} in recovery list", &address);
            }
        };
    }
}
