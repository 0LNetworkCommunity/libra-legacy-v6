//! MinerApp delay module
#![forbid(unsafe_code)]
use anyhow::{bail, Error};
/// Functions for running the VDF.
use vdf::{PietrzakVDFParams, VDFParams, VDF};

/// Runs the VDF
pub fn do_delay(preimage: &[u8], difficulty: u64, security: u64) -> Result<Vec<u8>, Error> {
    // Functions for running the VDF.
    let vdf: vdf::PietrzakVDF = PietrzakVDFParams(security as u16).new();
    match vdf.solve(preimage, difficulty) {
        Ok(proof) => Ok(proof),
        Err(e) => bail!(format!("ERROR: cannot solve VDF, message {:?}", e)),
    }
}

/// Verifies a proof
pub fn verify(preimage: &[u8], proof: &[u8], difficulty: u64, security: u16) -> bool {
    let vdf: vdf::PietrzakVDF = PietrzakVDFParams(security).new();

    match vdf.verify(preimage, difficulty, proof) {
        Ok(_) => true,
        Err(e) => {
            println!("Proof is not valid. {:?}", e);
            false
        }
    }
}
