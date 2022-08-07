//! Proof block datastructure

use hex;
use serde::{Deserialize, Serialize};

use std::{fs, io::BufReader, path::PathBuf};
/// Data structure and serialization of 0L delay proof.
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct VDFProof {
    /// Proof Height
    pub height: u64,
    /// Elapsed Time in seconds
    pub elapsed_secs: u64,
    /// VDF input preimage. AKA challenge
    #[serde(with = "hex")]
    pub preimage: Vec<u8>,
    /// VDF proof. AKA solution
    #[serde(with = "hex")]
    pub proof: Vec<u8>,
    /// The iterations of the circuit
    pub difficulty: Option<u64>, // option to make backwards compatible reads
    /// the security parameter of the proof.
    pub security: Option<u64>,
}

impl VDFProof {
    /// Extract the preimage and proof from a genesis proof proof_0.json
    pub fn get_genesis_tx_data(path: &PathBuf) -> Result<(Vec<u8>, Vec<u8>), std::io::Error> {
        let file = std::fs::File::open(path)?;
        let reader = std::io::BufReader::new(file);
        let block: VDFProof =
            serde_json::from_reader(reader).expect("Genesis block should deserialize");
        return Ok((block.preimage, block.proof));
    }

    /// new object deserialized from file
    pub fn parse_block_file(path: PathBuf) -> VDFProof {
        let file = fs::File::open(&path)
            .expect(&format!("Could not open block file: {:?}", path.to_str()));
        let reader = BufReader::new(file);
        serde_json::from_reader(reader).unwrap()
    }

    /// get the difficulty/iterations of the block, or assume legacy
    pub fn difficulty(&self) -> u64 {
        self.difficulty.unwrap() // if the block doesn't have this info, assume it's legacy block.
    }

    /// get the security param of the block, or assume legacy
    pub fn security(&self) -> u64 {
        self.security.unwrap() as u64 // if the block doesn't have this info, assume it's legacy block.
    }
}
