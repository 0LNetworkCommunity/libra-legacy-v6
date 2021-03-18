//! OlCli
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

pub mod application;
pub mod commands;
pub mod config;
pub mod error;
pub mod prelude;
pub mod account_resource;
pub mod client;
pub mod metadata;
pub mod monitor;
pub mod management;
pub mod check;
pub mod server;
pub mod restore;
pub mod sm;
pub mod onboard;