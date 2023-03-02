// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use diem_global_constants::{OWNER_ACCOUNT, OWNER_KEY};
use diem_management::{constants, error::Error, secure_backend::{SharedBackend, ValidatorBackend}};
use diem_types::{
    network_address::NetworkAddress, 
    transaction::{authenticator::AuthenticationKey, Transaction}
};
use structopt::StructOpt;
use diem_management::config::ConfigPath;
use diem_types::chain_id::{ChainId};

#[derive(Debug, StructOpt)]
pub struct ValidatorConfig {
    #[structopt(long)]
    owner_name: String,
    #[structopt(flatten)]
    validator_config: diem_management::validator_config::ValidatorConfig,
    #[structopt(long)]
    validator_address: NetworkAddress,
    #[structopt(long)]
    fullnode_address: NetworkAddress,
    #[structopt(flatten)]
    shared_backend: SharedBackend,
    #[structopt(long, help = "Disables network address validation")]
    disable_address_validation: bool,
}

impl ValidatorConfig {
    pub fn new(
        owner_name: String,
        validator_address: NetworkAddress,
        fullnode_address: NetworkAddress,
        shared_backend: &SharedBackend,
        validator_backend: &ValidatorBackend,
        disable_address_validation: bool,
        chain_id: ChainId,
    ) -> Self {
        Self {
            owner_name,
            validator_config: diem_management::validator_config::ValidatorConfig{
                config: ConfigPath { config: None},
                validator_backend: validator_backend.to_owned(),
                chain_id: Some(chain_id)
            },
            validator_address,
            fullnode_address,
            shared_backend: shared_backend.to_owned(),
            disable_address_validation
        }
    }

    pub fn execute(self) -> Result<Transaction, Error> {
        let config = self
            .validator_config
            .config()?
            .override_shared_backend(&self.shared_backend.shared_backend)?;

        //////// 0L //////// 
        // // Retrieve and set owner account
        // let owner_account =
        //     diem_config::utils::validator_owner_account_from_name(self.owner_name.as_bytes());
        let remote_storage = config.shared_backend_with_namespace(self.owner_name.into());
        let owner_key = remote_storage.ed25519_key(OWNER_KEY)?;
        let staged_owner_auth_key = AuthenticationKey::ed25519(&owner_key);
        let owner_account = staged_owner_auth_key.derived_address();
        //////// 0L ////////
        // This means Operators can only have 1 owner, at least at genesis.

        let mut validator_storage = config.validator_backend();
        validator_storage.set(OWNER_ACCOUNT, owner_account)?;

        let txn = self.validator_config.build_transaction(
            0,
            self.fullnode_address,
            self.validator_address,
            false,
            self.disable_address_validation,
        )?;

        // Upload the validator config to shared storage
        let mut shared_storage = config.shared_backend();
        shared_storage.set(constants::VALIDATOR_CONFIG, txn.clone())?;

        Ok(txn)
    }
}
