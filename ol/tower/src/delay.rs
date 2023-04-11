//! MinerApp delay module
#![forbid(unsafe_code)]
use anyhow::{anyhow, Error};
use diem_logger::error;
use diem_types::chain_id::{NamedChain, MODE_0L};
/// Functions for running the VDF.
use vdf::{PietrzakVDFParams, VDFParams, VDF, WesolowskiVDFParams};

/// Runs the VDF
pub fn do_delay(preimage: &[u8], difficulty: u64, security: u64) -> Result<Vec<u8>, Error> {
    // Functions for running the VDF.

    // TODO(Wiri): we need new fixtures so that we're not switching algorithms.
    let vdf = if
      MODE_0L.clone() == NamedChain::TESTNET || 
      MODE_0L.clone() == NamedChain::CI {
      let vdf = PietrzakVDFParams(security as u16).new();
      vdf.solve(preimage, difficulty)
    } else {
      let vdf = WesolowskiVDFParams(security as u16).new();
      vdf.solve(preimage, difficulty)
    };

    vdf.map_err(|e| {
        anyhow!("ERROR: cannot solve VDF, message: {:?}", &e)
    })
}

/// Verifies a proof
pub fn verify(preimage: &[u8], proof: &[u8], difficulty: u64, security: u16) -> bool {

    // TODO(Wiri): we need new fixtures so that we're not switching algorithms.
    let verifies = if
      MODE_0L.clone() == NamedChain::TESTNET || 
      MODE_0L.clone() == NamedChain::CI {
      let vdf = PietrzakVDFParams(security as u16).new();
      vdf.verify(preimage, difficulty, proof)
    } else {
      let vdf = WesolowskiVDFParams(security as u16).new();
      vdf.verify(preimage, difficulty, proof)
    };

    match verifies {
        Ok(_) => true,
        Err(e) => {
          error!("Proof is not valid. {:?}", &e);
          false
        },
    }
}
