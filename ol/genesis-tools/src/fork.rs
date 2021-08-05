//! fork

use vm_genesis::encode_genesis_transaction;

pub fn fork_genesis(path: PathBuf) {

    encode_genesis_transaction()

    let mut file = File::create(path).map_err(|e| {
        Error::UnexpectedError(format!("Unable to create genesis file: {}", e.to_string()))
    })?;
    let bytes = lcs::to_bytes(&genesis).map_err(|e| {
        Error::UnexpectedError(format!("Unable to serialize genesis: {}", e.to_string()))
    })?;
    file.write_all(&bytes).map_err(|e| {
        Error::UnexpectedError(format!("Unable to write genesis file: {}", e.to_string()))
    })?;
  
}
