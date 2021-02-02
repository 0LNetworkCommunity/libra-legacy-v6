use libra_management::{config::ConfigPath, error::Error, secure_backend::{ SharedBackend}};
// use miner::block::Block;
use std::path::PathBuf;
use structopt::StructOpt;
use serde_json;

#[derive(Debug, StructOpt)]
pub struct Mining {
    #[structopt(flatten)]
    config: ConfigPath,
    #[structopt(long, short)]
    pub path_to_genesis_pow: PathBuf,
    #[structopt(flatten)]
    shared_backend: SharedBackend,
}

impl Mining {
    pub fn execute(self) -> Result<String, Error> {
        let config = self
            .config
            .load()?
            .override_shared_backend(&self.shared_backend.shared_backend)?;

        
        let (preimage, proof) = get_genesis_tx_data(&self.path_to_genesis_pow)
            .map_err(|e| Error::UnexpectedError(e.to_string()))?;

        let mut shared_storage = config.shared_backend();
        shared_storage.set(libra_global_constants::PROOF_OF_WORK_PREIMAGE, preimage)?;
        shared_storage.set(libra_global_constants::PROOF_OF_WORK_PROOF, proof)?;


        // let mut remote: Box<dyn Storage> = self.backend.backend.try_into()?;
        // remote
        //     .available()
        //     .map_err(|e| Error::RemoteStorageUnavailable(e.to_string()))?;

        // remote
        //     .set(
        //         libra_global_constants::OPERATOR_PROOF_OF_WORK_PREIMAGE,
        //         preimage,
        //     )
        //     .map_err(|e| {
        //         Error::RemoteStorageWriteError(
        //             libra_global_constants::OPERATOR_PROOF_OF_WORK_PREIMAGE,
        //             e.to_string(),
        //         )
        //     })?;
        // remote
        //     .set(libra_global_constants::OPERATOR_PROOF_OF_WORK_PROOF, proof)
        //     .map_err(|e| {
        //         Error::RemoteStorageWriteError(
        //             libra_global_constants::OPERATOR_PROOF_OF_WORK_PROOF,
        //             e.to_string(),
        //         )
        //     })?;

        Ok("Sent Proof".to_string())
    }
}

pub fn get_genesis_tx_data(path: &std::path::PathBuf) -> Result<(String,String),std::io::Error> {
        let file = std::fs::File::open(path)?;
        let reader = std::io::BufReader::new(file);
        let json: serde_json::Value = serde_json::from_reader(reader).expect("Genesis block should deserialize");
        let block = json.as_object().unwrap();
        return Ok((
            block["preimage"].as_str().unwrap().to_owned(),
            block["preimage"].as_str().unwrap().to_owned()
        ));
    }