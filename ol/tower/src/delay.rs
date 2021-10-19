//! MinerApp delay module
#![forbid(unsafe_code)]

/// Functions for running the VDF.
use vdf::{VDFParams, WesolowskiVDFParams, VDF};
use std::env;

#[cfg(test)]
use std::{fs, io::Write};

/// Switch settings between production and testing
pub fn delay_difficulty() -> u64 {
    let node_env = match env::var("NODE_ENV") {
        Ok(val) => val,
        _ => "prod".to_string() // default to "prod" if not set
    };
    // must explicitly set env to prod to use production difficulty.
    if node_env == "prod" {
        return 5_000_000
    }
    return 100 // difficulty for test suites and on local for debugging purposes.
}

/// Runs the VDF
pub fn do_delay(preimage: &[u8], difficulty: u64, security: u16) -> Vec<u8> {
    // Functions for running the VDF.
    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    vdf.solve(preimage, difficulty)
        .expect("cannot create delay proof")
}

/// Verifies a proof
pub fn verify(preimage: &[u8], proof: &[u8], difficulty: u64, security: u16) -> bool{
    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    
    match vdf.verify(preimage, difficulty, proof) {
       Ok(_) => true,
       Err(e) => {
        println!("Proof is not valid. {:?}", e);
        false
       }
    }
}


#[test]
fn prove_100_512() {
    let security = 512;
    let difficulty = 100;
    let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();

    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    vdf.solve(preimage_bytes.as_slice(), difficulty)
        .expect("iterations should have been valiated earlier");
}

#[test]
fn prove_1000_512() {
    let security = 512;
    let difficulty = 1000;
    let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();

    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    vdf.solve(preimage_bytes.as_slice(), difficulty)
        .expect("iterations should have been valiated earlier");
}


#[test]
#[ignore] // only for creating test fixtures
fn prove_5m_2048() {
    let security = 2048;
    let difficulty = 5_000_000;
    let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();

    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    let proof = vdf.solve(preimage_bytes.as_slice(), difficulty)
        .expect("iterations should have been valiated earlier");
    let mut file = fs::File::create("./test.prove_5m_2048").unwrap();
    file.write_all(hex::encode(proof).as_bytes())
        .expect("Could not write block");
}

#[test]
#[ignore] // only for creating test fixtures

fn prove_5m_512() {
    let security = 512;
    let difficulty = 5_000_000;
    let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();

    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    let proof = vdf.solve(preimage_bytes.as_slice(), difficulty)
        .expect("iterations should have been valiated earlier");
    let mut file = fs::File::create("./test.prove_5m_512").unwrap();
    file.write_all(hex::encode(proof).as_bytes())
        .expect("Could not write block");
}

#[test]
#[ignore] // only for creating test fixtures

fn prove_5m_256() {
    let security = 256;
    let difficulty = 5_000_000;
    let preimage_bytes = hex::decode(ALICE_PREIMAGE).unwrap();

    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    let proof = vdf.solve(preimage_bytes.as_slice(), difficulty)
        .expect("iterations should have been valiated earlier");
    let mut file = fs::File::create("./test.prove_5m_256").unwrap();
    file.write_all(hex::encode(proof).as_bytes())
        .expect("Could not write block");
}

#[cfg(test)]
const ALICE_PREIMAGE: &str = "87515d94a244235a1433d7117bc0cb154c613c2f4b1e67ca8d98a542ee3f59f5000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304c20746573746e65746400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050726f74657374732072616765206163726f737320746865206e6174696f6e";