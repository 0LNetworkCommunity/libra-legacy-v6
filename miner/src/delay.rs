//! OlMiner delay module
#![forbid(unsafe_code)]


//! Functions for running the VDF.

use crate::application::SECURITY_PARAM;
use vdf::{VDFParams, WesolowskiVDFParams, VDF};
use std::env;

pub fn delay_difficulty() -> u64 {
    let node_env = match env::var("NODE_ENV") {
        Ok(val) => val,
        _ => "test".to_string() // default to "test" if not set
    };
    // must explicitly set env to prod to use production difficulty.
    if node_env == "prod" {
        return 2_400_000
    }
    return 100 // difficulty for test suites and on local for debugging purposes.
}

pub fn do_delay(preimage: &[u8]) -> Vec<u8> {
    let delay_length = delay_difficulty();
    // Functions for running the VDF.
    let vdf: vdf::WesolowskiVDF = WesolowskiVDFParams(SECURITY_PARAM).new();
    vdf.solve(preimage, delay_length)
        .expect("iterations should have been valiated earlier")
}
