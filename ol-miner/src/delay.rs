//! OlMiner delay module
#![forbid(unsafe_code)]


//! Functions for running the VDF.

use crate::application::SECURITY_PARAM;
use vdf::{VDFParams, WesolowskiVDFParams, VDF};

pub fn do_delay(preimage: &[u8], delay_length: u64) -> Vec<u8> {
    //! Functions for running the VDF.
    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(SECURITY_PARAM).new();
    vdf.solve(preimage, delay_length)
        .expect("iterations should have been valiated earlier")
}
