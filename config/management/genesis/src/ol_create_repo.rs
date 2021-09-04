// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use crate::layout::Layout;
use diem_global_constants::{OPERATOR_KEY, OWNER_KEY};
use diem_management::{config::ConfigPath, constants, error::Error, secure_backend::SharedBackend};
use diem_transaction_builder::stdlib as transaction_builder;
use diem_types::{
    account_address,
    chain_id::ChainId,
    transaction::{Transaction, TransactionPayload},
};
use std::{fs::File, io::Write, path::PathBuf, process::exit};
use structopt::StructOpt;
use vm_genesis::{OperatorAssignment, OperatorRegistration, GenesisMiningProof};
use diem_github_client::Client;

/// Note, it is implicitly expected that the storage supports
/// a namespace but one has not been set.
#[derive(Debug, StructOpt)]
pub struct NewRepo {
    #[structopt(flatten)]
    pub config: ConfigPath,
    #[structopt(long, required_unless("config"))]
    pub chain_id: Option<ChainId>,
    #[structopt(flatten)]
    pub backend: SharedBackend,
    #[structopt(long)]
    pub repo_name: String,
}

impl NewRepo {
    fn config(&self) -> Result<diem_management::config::Config, Error> {
        self.config
            .load()?
            .override_chain_id(self.chain_id)
            .override_shared_backend(&self.backend.shared_backend)
    }

    pub fn execute(self) -> Result<String, Error> {
        let config = self.config()?;
        match config.shared_backend {
            diem_config::config::SecureBackend::GitHub(config) => {
              let github = Client::new(config.repository_owner, config.repository, config.branch.unwrap_or("main".to_string()), config.token.read_token().expect("could not get github token"));
              match github.create_repo(&self.repo_name) {
                Ok(_) => Ok(format!("Created new repo {}", &self.repo_name)),
                Err(e) => Err(Error::StorageWriteError("github", "repo name", e.to_string())),
            }
            },
            _ => {
              println!("Not a github storage, exiting");
              exit(1);
            }
        }


    }

}
