use diem_management::{config::ConfigPath, error::Error, secure_backend::SharedBackend};
// use miner::block::Block;
use serde_json;
use std::{fs, path::PathBuf, process::exit};
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
pub struct Mining {
    #[structopt(flatten)]
    config: ConfigPath,
    #[structopt(long, short)]
    pub path_to_genesis_pow: PathBuf,
    #[structopt(flatten)]
    shared_backend: SharedBackend,
    #[structopt(long)]
    path_to_account_json: Option<PathBuf>,
}

impl Mining {
    pub fn execute(self) -> Result<String, Error> {
        let config = self
            .config
            .load()?
            .override_shared_backend(&self.shared_backend.shared_backend)?;

        let (preimage, proof) = get_proof_zero_data(&self.path_to_genesis_pow)
            .map_err(|e| Error::UnexpectedError(e.to_string()))?;

        let mut shared_storage = config.shared_backend();
        shared_storage.set(diem_global_constants::PROOF_OF_WORK_PREIMAGE, preimage)?;
        shared_storage.set(diem_global_constants::PROOF_OF_WORK_PROOF, proof)?;
        
        if let Some(path) = &self.path_to_account_json {
          let string = fs::read_to_string(path).unwrap_or_else(|_| {
            println!("ERROR: account.json path with genesis preferences was not found at: {:?}, exiting.", &self.path_to_account_json);
            exit(1);
          });
          shared_storage.set(diem_global_constants::ACCOUNT_PROFILE, string)?;
        }

        Ok("Sent Proof".to_string())
    }
}

// TODO: This can be retrieved from profile data as well. So it's duplicated.
pub fn get_proof_zero_data(path: &std::path::PathBuf) -> Result<(String, String), std::io::Error> {
    let file = std::fs::File::open(path)?;
    let reader = std::io::BufReader::new(file);
    let json: serde_json::Value =
        serde_json::from_reader(reader).expect("Genesis block should deserialize");
    let block = json.as_object().unwrap();
    return Ok((
        block["preimage"].as_str().unwrap().to_owned(),
        block["proof"].as_str().unwrap().to_owned(),
    ));
}
