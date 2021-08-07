//! OlCli
#![forbid(unsafe_code)]
#![warn(
    missing_docs,
    rust_2018_idioms,
    trivial_casts,
    unused_lifetimes,
    unused_qualifications
)]

pub mod fetch_archive;
pub mod fork_daemon;
pub mod read_archive;
pub mod generate_genesis;
pub mod recover;
pub mod fork_genesis;
pub mod swarm_genesis;