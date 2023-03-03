//! Proof block datastructure

use diem_types::chain_id::{MODE_0L, NamedChain};
use hex;
use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};

use std::{fs, io::BufReader, path::PathBuf};


// TOWER DIFFICULTY SETTINGS
// What we call "difficulty", is the intersection of number of VDF iterations with the security parameter.

// V6: Difficulty updated in V6
// see benchmarking research summary here: ol/documentation/tower/difficulty_benchmarking.md

/// The VDF security parameter.
pub static GENESIS_VDF_SECURITY_PARAM: Lazy<u64> = Lazy::new(|| {
    match MODE_0L.clone() {

        NamedChain::MAINNET => 350,
        NamedChain::STAGE => 350,
        NamedChain::TESTNET => 512, // TODO(wiri): this should be updated to 350 after new fixtures are generated.
        NamedChain::CI => 512,
    }
});


/// The VDF iterations. Combined with security parameter we have the "difficulty".
pub static GENESIS_VDF_ITERATIONS: Lazy<u64> = Lazy::new(|| {
    match MODE_0L.clone() {
        // Difficulty updated in V6
        // see ol/documentation/tower/difficulty_benchmarking.md
        NamedChain::MAINNET => 3_000_000_000, // 3 billion, ol/documentation/tower/difficulty_benchmarking.md
        NamedChain::STAGE => 3_000_000_000,
        NamedChain::TESTNET => 100,
        NamedChain::CI => 100,
    }
});

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
