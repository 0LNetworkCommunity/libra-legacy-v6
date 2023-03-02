// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use consensus_types::safety_data::SafetyData;
use diem_crypto::ed25519::Ed25519PublicKey;
use diem_global_constants::{GENESIS_WAYPOINT, OPERATOR_ACCOUNT, OWNER_ACCOUNT, WAYPOINT, SAFETY_DATA};
use diem_management::{
    config::ConfigPath,
    error::Error,
    secure_backend::{SharedBackend, ValidatorBackend},
};
use std::{ path::PathBuf, str::FromStr};
use diem_secure_storage::{
    CryptoStorage, OnDiskStorage, KVStorage
};
use diem_types::{waypoint::Waypoint, account_address::AccountAddress};
use structopt::StructOpt;

// diem_management::secure_backend!(
//     ValidatorBackend,
//     validator_backend,
//     "validator configuration",
//     "path-to-key"
// );

#[derive(Debug, StructOpt)]
pub struct Key {
    #[structopt(flatten)]
    config: ConfigPath,
    #[structopt(flatten)]
    shared_backend: SharedBackend,
    #[structopt(flatten)]
    validator_backend: ValidatorBackend,
    #[structopt(long, help = "ed25519 public key in bcs or hex format")]
    path_to_key: Option<PathBuf>,
}

impl Key {
    pub fn new(validator_backend: &ValidatorBackend, shared_backend: &SharedBackend) -> Self {
        Self {
            config: ConfigPath { config: None },
            shared_backend: shared_backend.to_owned(),
            validator_backend: validator_backend.to_owned(),
            path_to_key: None,
        }
    }
  pub fn shared_backend(namespace: String, github_org: String, repo_name: String, data_path: PathBuf) -> anyhow::Result<SharedBackend> {

  // BLACK MAGIC with MACROS 
  // ... AND STRING FORMATTING 
  // I curse your first born.

  let storage_cfg = format!(
      "backend=github;repository_owner={github_org};repository={repo_name};token={data_path}/github_token.txt;namespace={namespace}",
      namespace = namespace,
      github_org = github_org,
      repo_name = repo_name,
      data_path = data_path.to_str().unwrap(),
    );

    Ok(SharedBackend::from_str(storage_cfg.as_str())?)

  }

  pub fn validator_backend(namespace: String, data_path: PathBuf) -> anyhow::Result<ValidatorBackend> {

    let storage_cfg = format!(
      "backend=disk;path={data_path}key_store.json;namespace={namespace}",
        namespace = namespace,
        data_path = data_path.to_str().unwrap(),
      );

    Ok(ValidatorBackend::from_str(storage_cfg.as_str())?)

  }

    fn submit_key(
        &self,
        key_name: &'static str,
        account_name: Option<&'static str>,
    ) -> Result<Ed25519PublicKey, Error> {
        let config = self
            .config
            .load()?
            .override_shared_backend(&self.shared_backend.shared_backend)?
            .override_validator_backend(&self.validator_backend.validator_backend)?;

        let key = if let Some(path_to_key) = &self.path_to_key {
            diem_management::read_key_from_file(path_to_key)
                .map_err(|e| Error::UnableToReadFile(format!("{:?}", path_to_key), e))?
        } else {
            let mut validator_storage = config.validator_backend();
            let key = validator_storage.ed25519_public_from_private(key_name)?;

            if let Some(account_name) = account_name {
                let peer_id = diem_types::account_address::from_public_key(&key);
                validator_storage.set(account_name, peer_id)?;
            }
            key
        };

        let mut shared_storage = config.shared_backend();
        shared_storage.set(key_name, key.clone())?;

        Ok(key)
    }
}

//////// 0L /////////
pub fn set_operator_key(path: &PathBuf, namespace: &str) {
    let mut storage = diem_secure_storage::Storage::OnDiskStorage(
        OnDiskStorage::new(path.join("key_store.json").to_owned())
    );
    // TODO: Remove hard coded field
    let field = format!("{}/operator", namespace);
    let key = storage.get_public_key(&field).unwrap().public_key;
    let peer_id = diem_types::account_address::from_public_key(&key);
    storage.set(OPERATOR_ACCOUNT, peer_id).unwrap();
}

//////// 0L /////////
pub fn set_owner_address(path: &PathBuf, namespace: &str, account: AccountAddress) {
    let mut storage = diem_secure_storage::Storage::OnDiskStorage(
        OnDiskStorage::new(path.join("key_store.json").to_owned())
    );
    // let authkey: AuthenticationKey = namespace.parse().unwrap();
    // let account = authkey.derived_address();
    storage.set(&format!("{}/{}", namespace, OWNER_ACCOUNT), account).unwrap();
    // storage.set(&format!("{}/{}", namespace, OWNER_ACCOUNT), account).unwrap();

}

//////// 0L /////////
pub fn reset_safety_data(path: &PathBuf, namespace: &str) {
    let mut storage = diem_secure_storage::Storage::OnDiskStorage(
        OnDiskStorage::new(path.join("key_store.json").to_owned())
    );
    let key = &format!("{}/{}", namespace, SAFETY_DATA);
    storage
      .set(key, SafetyData::new(0, 0, 0, 0, None))
        // 0L todo: review `one_chain_round` arg value
      .unwrap();
}

//////// 0L /////////
pub fn set_waypoint(path: &PathBuf, namespace: &str, waypoint: Waypoint) {
    let mut storage = diem_secure_storage::Storage::OnDiskStorage(
        OnDiskStorage::new(path.join("key_store.json").to_owned())
    );
    storage.set(&format!("{}/{}", namespace, WAYPOINT), waypoint).unwrap();
}

//////// 0L /////////
pub fn set_genesis_waypoint(path: &PathBuf, namespace: &str, waypoint: Waypoint) {
    let mut storage = diem_secure_storage::Storage::OnDiskStorage(
        OnDiskStorage::new(path.join("key_store.json").to_owned())
    );
    storage.set(&format!("{}/{}", namespace, GENESIS_WAYPOINT), waypoint).unwrap();
}

#[derive(Debug, StructOpt)]
pub struct DiemRootKey {
    #[structopt(flatten)]
    key: Key,
}

impl DiemRootKey {
    pub fn execute(self) -> Result<Ed25519PublicKey, Error> {
        self.key
            .submit_key(diem_global_constants::DIEM_ROOT_KEY, None)
    }
}

#[derive(Debug, StructOpt)]
pub struct OperatorKey {
    #[structopt(flatten)]
    pub key: Key, ///////// 0L ////////
}

impl OperatorKey {
    pub fn execute(self) -> Result<Ed25519PublicKey, Error> {
        self.key.submit_key(
            diem_global_constants::OPERATOR_KEY,
            Some(diem_global_constants::OPERATOR_ACCOUNT),
        )
    }
}

#[derive(Debug, StructOpt)]
pub struct OwnerKey {
    #[structopt(flatten)]
    pub key: Key, //////// 0L ////////
}

impl OwnerKey {
    pub fn execute(self) -> Result<Ed25519PublicKey, Error> {
        self.key.submit_key(diem_global_constants::OWNER_KEY, None)
    }
}

#[derive(Debug, StructOpt)]
pub struct TreasuryComplianceKey {
    #[structopt(flatten)]
    key: Key,
}

impl TreasuryComplianceKey {
    pub fn execute(self) -> Result<Ed25519PublicKey, Error> {
        self.key
            .submit_key(diem_global_constants::TREASURY_COMPLIANCE_KEY, None)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::storage_helper::StorageHelper;
    use diem_secure_storage::{CryptoStorage, KVStorage};

    #[test]
    fn test_owner_key() {
        test_key(diem_global_constants::OWNER_KEY, StorageHelper::owner_key);
    }

    #[test]
    fn test_operator_key() {
        test_key(
            diem_global_constants::OPERATOR_KEY,
            StorageHelper::operator_key,
        );
    }

    fn test_key(
        key_name: &str,
        op: fn(&StorageHelper, &str, &str) -> Result<Ed25519PublicKey, Error>,
    ) {
        let helper = StorageHelper::new();
        let local_ns = format!("local_{}_key", key_name);
        let remote_ns = format!("remote_{}_key", key_name);

        op(&helper, &local_ns, &remote_ns).unwrap_err();

        helper.initialize_by_idx(local_ns.clone(), 0);
        let local = helper.storage(local_ns.clone());
        let local_key = local.get_public_key(key_name).unwrap().public_key;

        let output_key = op(&helper, &local_ns, &remote_ns).unwrap();
        let remote = helper.storage(remote_ns);
        let remote_key = remote.get::<Ed25519PublicKey>(key_name).unwrap().value;

        assert_eq!(local_key, output_key);
        assert_eq!(local_key, remote_key);
    }
}
