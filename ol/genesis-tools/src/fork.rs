//! fork

use std::path::PathBuf;

use anyhow::Error;


/// takes a recovery file and produces a genesis file
pub fn fork_genesis(_recovery_file: PathBuf, _output_genesis: PathBuf) -> Result<(), Error> {

    // let genesis = encode_recovery_genesis_transaction();
    Ok(())

    // let mut file = File::create(path).map_err(|e| {
    //     Error::UnexpectedError(format!("Unable to create genesis file: {}", e.to_string()))
    // })?;
    // let bytes = lcs::to_bytes(&genesis).map_err(|e| {
    //     Error::UnexpectedError(format!("Unable to serialize genesis: {}", e.to_string()))
    // })?;
    // file.write_all(&bytes).map_err(|e| {
    //     Error::UnexpectedError(format!("Unable to write genesis file: {}", e.to_string()))
    // })?;
  
}
