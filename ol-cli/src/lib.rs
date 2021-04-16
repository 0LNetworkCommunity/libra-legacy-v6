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
pub mod client;
pub mod node;
pub mod mgmt;
pub mod transitions;
pub mod cache;
pub mod check;
pub mod explorer;
