//! OlCli
#![forbid(unsafe_code)]
#![warn(
    missing_docs,
    rust_2018_idioms,
    trivial_casts,
    unused_lifetimes,
    unused_qualifications
)]

pub mod application;
pub mod cache;
pub mod check;
pub mod commands;
pub mod config;
pub mod entrypoint;
pub mod error;
pub mod mgmt;
pub mod node;
pub mod prelude;
pub mod server;
// pub mod migrate;
