// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

use diem_github_client::Client;
use diem_management::{config::ConfigPath, error::Error, secure_backend::SharedBackend};
use std::{process::exit, path::PathBuf, fs::File};
use structopt::StructOpt;
use std::io::prelude::*;

/// Note, it is implicitly expected that the storage supports
/// a namespace but one has not been set.
#[derive(Debug, StructOpt)]
pub struct CreateGenesisRepo {
    #[structopt(flatten)]
    pub config: ConfigPath,
    // #[structopt(long, required_unless("config"))]
    // pub chain_id: Option<ChainId>,
    #[structopt(flatten)]
    pub backend: SharedBackend,
    #[structopt(long)]
    pub repo_owner: Option<String>,
    #[structopt(long)]
    pub repo_name: Option<String>,
    #[structopt(long)]
    pub pull_request_user: Option<String>,
    #[structopt(long)]
    pub delete_repo_user: Option<String>,
    #[structopt(long)]
    pub publish_genesis: Option<PathBuf>,
}

impl CreateGenesisRepo {
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
                    config.branch.unwrap_or("master".to_string()),
                    config
                        .token
                        .read_token()
                        .expect("could not get github token"),
                );

                if let Some(p) = self.publish_genesis {
                  

                  let mut file = File::open(&p)
                  .expect("cannot read file");

                  let mut bytes = Vec::new();
                  file.read_to_end(&mut bytes).expect("could not read file");
                  let base64_encoded = base64::encode(bytes);

                  let repo_file_path = format!("genesis/{}", p.file_name().unwrap().to_str().unwrap());

                  github.put(&repo_file_path, &base64_encoded).expect("could not put file in github repo");

                  return Ok(format!("published file to genesis repo at {:?}", &repo_file_path));
                }
                // Make a pull request of the the forked repo, back to the genesis coordination repository.
                if let Some(user) = self.pull_request_user {
                    match github.make_genesis_pull_request(&config.repository_owner, &config.repository, &user) {
                        Ok(_) => Ok("created pull request to genesis repo".to_string()),
                        Err(e) => Err(Error::StorageWriteError(
                            "github",
                            "pull request",
                            e.to_string(),
                        )),
                    }
                } else if let Some(user) = self.delete_repo_user{
                    match github.delete_own_repo(&user, &config.repository) {
                        Ok(_) => Ok("created pull request to genesis repo".to_string()),
                        Err(e) => Err(Error::StorageWriteError(
                            "github",
                            "pull request",
                            e.to_string(),
                        )),
                    }
                } else {
                // Fork the genesis coordination repo into a personal repo
                    match github.fork_genesis_repo(&self.repo_owner.unwrap(), &self.repo_name.as_ref().unwrap()) {
                        Ok(_) => Ok(format!("Created new repo {}", &self.repo_name.unwrap())),
                        Err(e) => Err(Error::StorageWriteError(
                            "github",
                            "fork genesis repo",
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

