//! Main entry point for MinerApp

#![deny(warnings, missing_docs, trivial_casts, unused_qualifications)]
#![forbid(unsafe_code)]

use txs::application::APPLICATION;
use std::env;

/// Boot MinerApp
fn main() {
    for argument in env::args() {
        println!("--- args: {}", argument);
    }

    abscissa_core::boot(&APPLICATION);
}
