//! MinerApp delay module
#![forbid(unsafe_code)]
/// Functions for running the VDF.
use vdf::{PietrzakVDFParams, VDF, VDFParams};

#[cfg(test)]
use std::{fs, io::Write};

/// Runs the VDF
pub fn do_delay(preimage: &[u8], difficulty: u64, security: u16) -> Vec<u8> {
    // Functions for running the VDF.
    let vdf: vdf::PietrzakVDF = PietrzakVDFParams(security).new();
    vdf.solve(preimage, difficulty)
        .expect("cannot create delay proof")
    // let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(security).new();
    // vdf.solve(preimage, difficulty)
    //     .expect("cannot create delay proof")
}

/// Verifies a proof
pub fn verify(preimage: &[u8], proof: &[u8], difficulty: u64, security: u16) -> bool{
    let vdf: vdf::PietrzakVDF = PietrzakVDFParams(security).new();
    
    match vdf.verify(preimage, difficulty, proof) {
       Ok(_) => true,
       Err(e) => {
        println!("Proof is not valid. {:?}", e);
        false
       }
    }
}
