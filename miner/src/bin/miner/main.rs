//! Main entry point for OlMiner

#![deny(warnings, missing_docs, trivial_casts, unused_qualifications)]
#![forbid(unsafe_code)]

use miner::application::APPLICATION;

/// Boot OlMiner
fn main() {
    abscissa_core::boot(&APPLICATION);
}
