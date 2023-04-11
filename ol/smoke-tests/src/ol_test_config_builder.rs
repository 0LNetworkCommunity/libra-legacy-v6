// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

// NOTE: This is modified from /config/management/genesis/src/config_builder.rs
use diem_genesis_tool::validator_builder::{ValidatorBuilder, ValidatorConfig};
use diem_config::config::NodeConfig;
use diem_crypto::ed25519::Ed25519PrivateKey;
use diem_management::validator_config;
use diem_secure_storage::{CryptoStorage, KVStorage, Storage};
use diem_temppath::TempPath;
use diem_types::{transaction::ChangeSet, chain_id};
use diem_writeset_generator::admin_script_builder;
use rand::{rngs::StdRng, SeedableRng};
use diem_global_constants::OWNER_ACCOUNT;
use diem_types::account_address::AccountAddress;
use diem_types::transaction::Transaction;

/////// 0L ////////
pub fn test_config(persist: bool) -> (NodeConfig, Ed25519PrivateKey) {
    let mut path = TempPath::new();
    path.create_as_dir().unwrap();
    if persist {
        path.persist();
    }
    diem_logger::info!("config path: {:?}", path.path().to_str().unwrap());

    // do a bunch of stuff to get a config
    // runs a genesis ceremony from one node, with a single random validator config.
    let (root_keys, _genesis, _genesis_waypoint, validators) = ValidatorBuilder::new(
        path.path(),
        diem_framework_releases::current_module_blobs().to_vec(),
    )
    .template(NodeConfig::default_for_validator())
    .build(StdRng::from_seed([0; 32]))
    .unwrap();

    let root_pri_key = root_keys.root_key;

    let val_cfg = validators.iter().next().unwrap();
    let mut config = val_cfg.config.to_owned();
    // .get(0).expect("where's the val config?").clone().config;
    config.set_data_dir(path.path().to_path_buf());
    let backend = &config
        .validator_network
        .as_ref()
        .unwrap()
        .identity_from_storage()
        .backend;
    let storage: Storage = std::convert::TryFrom::try_from(backend).unwrap();

    // Now we are configuring this node as a "test" node. This means we place a number of keys into the config file itself. (As opposed the secure-storage.json).
    // NOTE: 0L: unclear why this needs to happen for our purposes. (e.g. starting a node with a specific genesis).

    let mut test = diem_config::config::TestConfig::new_with_temp_dir(Some(path));
    test.execution_key(
        storage
            .export_private_key(diem_global_constants::EXECUTION_KEY)
            .unwrap(),
    );
    test.operator_key(
        storage
            .export_private_key(diem_global_constants::OPERATOR_KEY)
            .unwrap(),
    );
    test.owner_key(
        storage
            .export_private_key(diem_global_constants::OWNER_KEY)
            .unwrap(),
    );
    config.test = Some(test);

    // Since we are starting a "test" type node, we want to place the "safety rules" information in the config file itself. And not in the secure-storage.json as in production.
    let owner_account = storage
        .get(diem_global_constants::OWNER_ACCOUNT)
        .unwrap()
        .value;
    let mut sr_test = diem_config::config::SafetyRulesTestConfig::new(owner_account);
    sr_test.consensus_key(
        storage
            .export_private_key(diem_global_constants::CONSENSUS_KEY)
            .unwrap(),
    );
    sr_test.execution_key(
        storage
            .export_private_key(diem_global_constants::EXECUTION_KEY)
            .unwrap(),
    );
    config.consensus.safety_rules.test = Some(sr_test);

    (config, root_pri_key)
}

/// Replace the Genesis file
/// Note, if your genesis file does not contain the test config validator keys, the blockchain will start but will not be able to make progress.

pub fn replace_genesis_validators_tx(validator: ValidatorConfig, _base_genesis: ChangeSet) -> Result<(), anyhow::Error>{

  // add the test validator network configs to the genesis with a transaction.
    let _validator_config = validator_config::build_validator_config_transaction(
      validator.storage(),
      chain_id::ChainId::test(),
      0, // sequence_number
      validator.config.full_node_networks[0]
          .listen_address
          .clone(),
      validator
          .config
          .validator_network
          .as_ref()
          .map(|a| a.listen_address.clone())
          .unwrap(),
      false, // This isn't a reconfiguration
      false, // Don't disable address validation
  )?;

  // let addr = validator.storage().get(OWNER_ACCOUNT).unwrap().value;
  
  let owner_account = validator.storage()
        .get::<AccountAddress>(OWNER_ACCOUNT)
        .map(|v| v.value)?;

  admin_script_builder::script_bulk_update_vals_payload(
    vec![owner_account],
  );
  // replace the validator set with the new validator config.
  // must issue a reconfiguration event.
  Ok(())

}
pub fn replace_test_genesis(_validator: ValidatorConfig, _genesis: &Transaction) {
  // the test generator creates a blob file. We may not want to use it depending on our needs. For example: if we are testing a migration, we want 
  // to use a specific genesis and only replace the validators with a single test validator.
  // validator.insert_genesis(genesis);
  // insert the genesis binary into the config file (not reading from a separate .blob file.)
}