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
pub mod entrypoint;
pub mod error;
pub mod prelude;
/// node
pub mod node;
/// mgmt
pub mod mgmt;
/// cache
pub mod cache;
/// check
pub mod check;
/// explorer
pub mod explorer;
/// web monitor server
pub mod server;
