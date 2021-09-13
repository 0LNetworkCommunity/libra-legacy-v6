// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use diem_github_client::Client;
use diem_management::{config::ConfigPath, error::Error, secure_backend::SharedBackend};
use std::process::exit;
use structopt::StructOpt;

/// Note, it is implicitly expected that the storage supports
/// a namespace but one has not been set.
#[derive(Debug, StructOpt)]
pub struct NewRepo {
    #[structopt(flatten)]
    pub config: ConfigPath,
    // #[structopt(long, required_unless("config"))]
    // pub chain_id: Option<ChainId>,
    #[structopt(flatten)]
    pub backend: SharedBackend,
    #[structopt(long)]
    pub repo_owner: String,
    #[structopt(long)]
    pub repo_name: String,
    #[structopt(long)]
    pub pull_username: Option<String>,
}

impl NewRepo {
    fn config(&self) -> Result<diem_management::config::Config, Error> {
        self.config
            .load()?
            // .override_chain_id(self.chain_id)
            .override_shared_backend(&self.backend.shared_backend)
    }

    pub fn execute(self) -> Result<String, Error> {
        let config = self.config()?;
        match config.shared_backend {
            diem_config::config::SecureBackend::GitHub(config) => {
                let github = Client::new(
                    config.repository_owner.clone(),
                    config.repository.clone(),
                    config.branch.unwrap_or("main".to_string()),
                    config
                        .token
                        .read_token()
                        .expect("could not get github token"),
                );
                if let Some(user) = self.pull_username {
                    match github.create_pull(&config.repository_owner, &config.repository, &user) {
                        Ok(_) => Ok("created pull request to genesis repo".to_string()),
                        Err(e) => Err(Error::StorageWriteError(
                            "github",
                            "fork",
                            e.to_string(),
                        )),
                    }
                } else {
                    match github.create_repo(&self.repo_owner, &self.repo_name) {
                        Ok(_) => Ok(format!("Created new repo {}", &self.repo_name)),
                        Err(e) => Err(Error::StorageWriteError(
                            "github",
                            "repo name",
                            e.to_string(),
                        )),
                    }
                }
            }
            _ => {
                println!("Not a github storage, exiting");
                exit(1);
            }
        }
    }
}
