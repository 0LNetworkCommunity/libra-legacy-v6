//! Proof block datastructure

use hex;
use serde::{Deserialize, Serialize};

use std::{fs, io::BufReader, path::PathBuf};
/// Data structure and serialization of 0L delay proof.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct Block {
    /// Block Height
    pub height: u64,
    /// Elapsed Time in seconds
    pub elapsed_secs: u64,
    /// VDF input preimage. AKA challenge
    #[serde(with = "hex")]
    pub preimage: Vec<u8>,
    /// VDF proof. AKA solution
    #[serde(with = "hex")]
    pub proof: Vec<u8>,
}

impl Block {

    /// Extract the preimage and proof from a genesis proof block_0.json
    pub fn get_genesis_tx_data(path: &PathBuf) -> Result<(Vec<u8>,Vec<u8>),std::io::Error> {
        let file = std::fs::File::open(path)?;
        let reader = std::io::BufReader::new(file);
        let block: Block = serde_json::from_reader(reader).expect("Genesis block should deserialize");
        return Ok((block.preimage, block.proof));
    }

    /// new object deserialized from file
    pub fn parse_block_file(path: PathBuf) -> Block{
        let file = fs::File::open(&path).expect(&format!("Could not open block file: {:?}", path.to_str()));
        let reader = BufReader::new(file);
        serde_json::from_reader(reader).unwrap()
    }
}
