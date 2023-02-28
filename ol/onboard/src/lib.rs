//! MinerApp
//!
//! Application based on the [Abscissa] framework.

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
pub mod prelude;
pub mod wizard;