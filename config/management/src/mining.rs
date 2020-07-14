use crate::{error::Error, SingleBackend};
use libra_secure_storage::{Storage, Value};
use ol_miner::block::Block;
use std::convert::TryInto;
use std::path::PathBuf;
use structopt::StructOpt;

#[derive(Debug, StructOpt)]
pub struct Mining {
    pub path_to_genesis_pow: PathBuf,
    #[structopt(flatten)]
    pub backend: SingleBackend,
}

impl Mining {
    pub fn execute(self) -> Result<String, Error> {
        let (preimage, proof) = Block::get_genesis_tx_data(self.path_to_genesis_pow)
            .map_err(|e| Error::UnexpectedError(e.to_string()))?;

            let preimage = Value::String(preimage);
            let proof = Value::String(proof);
            let mut remote: Box<dyn Storage> = self.backend.backend.try_into()?;
            remote
                .available()
                .map_err(|e| Error::RemoteStorageUnavailable(e.to_string()))?;

            remote
                .set("proof_of_work_preimage", preimage)
                .map_err(|e| {
                    Error::RemoteStorageWriteError(
                        libra_global_constants::OPERATOR_PROOF_OF_WORK_PREIMAGE,
                        e.to_string(),
                    )
                })?;
            remote
                .set(libra_global_constants::OPERATOR_PROOF_OF_WORK_PROOF, proof)
                .map_err(|e| {
                    Error::RemoteStorageWriteError("proof_of_work_proof", e.to_string())
                })?;

        Ok("Sent Proof".to_string())
    }
}
