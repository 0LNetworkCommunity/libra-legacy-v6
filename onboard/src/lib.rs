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
    unused_qualifications,
    unused_extern_crates
)]

pub mod application;
pub mod commands;
pub mod entrypoint;
pub mod error;
pub mod manifest;
pub mod prelude;
// pub mod home;
pub mod read_genesis;
