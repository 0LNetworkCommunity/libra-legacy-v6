// Copyright (c) The Libra Core Contributors
// SPDX-License-Identifier: Apache-2.0

use libra_global_constants::{OWNER_ACCOUNT, OWNER_KEY};
use libra_management::{constants, error::Error, secure_backend::SharedBackend};
use libra_network_address::NetworkAddress;
use libra_types::transaction::{authenticator::AuthenticationKey, Transaction};
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
pub struct ValidatorConfig {
    #[structopt(long)]
    owner_name: String,
    #[structopt(flatten)]
    validator_config: libra_management::validator_config::ValidatorConfig,
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
    pub fn execute(self) -> Result<Transaction, Error> {
        let config = self
            .validator_config
            .config()?
            .override_shared_backend(&self.shared_backend.shared_backend)?;

        // Retrieve and set owner account
        let remote_storage = config.shared_backend_with_namespace(self.owner_name.into());
        let owner_key = remote_storage.ed25519_key(OWNER_KEY)?;
        let staged_owner_auth_key = AuthenticationKey::ed25519(&owner_key);
        let owner_account = staged_owner_auth_key.derived_address();

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
