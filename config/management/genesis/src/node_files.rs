use std::path::PathBuf;

use libra_management::{
    secure_backend::ValidatorBackend,
    error::Error
};
use libra_network_address::NetworkAddress;
use structopt::StructOpt;


#[derive(Debug, StructOpt)]
pub struct Files {
    #[structopt(flatten)]
    backend: ValidatorBackend,
    #[structopt(long)]
    validator_address: NetworkAddress,
    #[structopt(long)]
    validator_listen_address: NetworkAddress,
    #[structopt(long)]
    fullnode_address: NetworkAddress,
    #[structopt(long)]
    fullnode_listen_address: NetworkAddress,
    #[structopt(long)]
    path: Option<PathBuf>,
}

impl Files {
    pub fn execute(self) -> Result<String, Error> {
        Ok("test".to_owned())
    }
}
