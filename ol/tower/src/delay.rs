//! MinerApp delay module
#![forbid(unsafe_code)]
/// Functions for running the VDF.
use vdf::{VDFParams, WesolowskiVDFParams, VDF};

#[cfg(test)]
use std::{fs, io::Write};

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

// #[test]
// fn verify_10_000_001_256_and_verify() {
//     let security = 256;
//     let difficulty = 10_000_001;
//     let preimage = "df6046be26c9a64ececa098a5ecbf724d91619ce64a4899087ac2098d394df59";
//     let preimage_bytes = hex::decode(preimage).unwrap();

//     let proof = "005e7aa10240f31b5ca8f0f4a736ee835bffb6d5207bccca69a720f24e840783badf0014d515be4562e96463391813ff49468700023e54763cf578330bd9d15e2510faef";
//     let proof_bytes =  hex::decode(proof).unwrap();

//     let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
//     // let proof = vdf.solve(preimage_bytes.as_slice(), difficulty)
//     //     .expect("iterations should have been valiated earlier");
    
//     match vdf.verify(&preimage_bytes, difficulty, &proof_bytes) {
//         Ok(_) => println!("proof is ok"),
//         Err(e) => {
//           dbg!(&e);
//         },
//     }

//     // let mut file = fs::File::create("./test.prove_5m_512").unwrap();
//     // file.write_all(hex::encode(proof).as_bytes())
//     //     .expect("Could not write block");
// }


#[test]
fn roundtrip_10_000_001_256() {
    let security = 256;
    let difficulty = 10_000_001;
    let preimage = "df6046be26c9a64ececa098a5ecbf724d91619ce64a4899087ac2098d394df59";
    let preimage_bytes = hex::decode(preimage).unwrap();

    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    let proof_bytes = vdf.solve(preimage_bytes.as_slice(), difficulty)
        .expect("iterations should have been valiated earlier");
    
    match vdf.verify(&preimage_bytes, difficulty, &proof_bytes) {
        Ok(_) => println!("proof is ok"),
        Err(e) => {
          dbg!(&e);
        },
    }
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