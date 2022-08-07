//! MinerApp
//!
//! Application based on the [Abscissa] framework.
//!
//! [Abscissa]: https://github.com/iqlusioninc/abscissa

// Tip: Deny warnings with `RUSTFLAGS="-D warnings"` environment variable in CI

#![forbid(unsafe_code)]
#![warn(
    missing_docs,
    rust_2018_idioms,
    trivial_casts,
    unused_lifetimes,
    unused_qualifications
)]

// TODO: make these a query to chain.
/// min proofs that can be submitted in an epoch
pub const EPOCH_MINING_THRES_LOWER: u64 = 7;
/// max proofs that can be submitted in an epoch
pub const EPOCH_MINING_THRES_UPPER: u64 = 72;

pub mod application;
pub mod commands;
pub mod entrypoint;
pub mod error;
pub mod prelude;

pub mod backlog;
pub mod commit_proof;
pub mod delay;
pub mod garbage_collection;
pub mod next_proof;
pub mod preimage;
pub mod proof;
pub mod tower_errors;
