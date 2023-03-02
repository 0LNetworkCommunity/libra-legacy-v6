//! OlCli
#![forbid(unsafe_code)]
#![warn(
    missing_docs,
    rust_2018_idioms,
    trivial_casts,
    unused_lifetimes,
    unused_qualifications
)]

// pub mod fetch_archive; // Deprecated. Validators will fetch backup zip manually.
// pub mod fork_daemon; // Note: 0L deleted: This is feature (fork daemon shouldn't be exposed yet, it will not ship with this version of the recovery tool)
pub mod compare;
pub mod db_utils;
pub mod fork_genesis;
pub mod process_snapshot;
pub mod read_snapshot;
pub mod wizard;
pub mod run;

// pub mod swarm_genesis; // Note: 0L deleted: starting a test environment (Swarm in v5) has changed. Now we would use Forge. And that would be external to main code. Either in ./src/tests or in the Smoke tests directory.
