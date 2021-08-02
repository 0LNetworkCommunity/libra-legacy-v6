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
pub mod live_fork;
pub mod read_archive;
pub mod generate_genesis;
pub mod fork;