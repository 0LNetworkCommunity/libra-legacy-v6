//! `ol-util`

#![forbid(unsafe_code)]
#![warn(
    missing_docs,
    rust_2018_idioms,
    trivial_casts,
    unused_lifetimes,
    unused_qualifications
)]

pub mod account;
pub mod pay_instruction;
pub mod block;
pub mod config;
pub mod dialogue;
pub mod autopay;
pub mod validator_config;
pub mod fullnode_counter;
pub mod wallet;
pub mod genesis_proof;
pub mod fixtures;
pub mod rpc_playlist;
pub mod epoch_timer;