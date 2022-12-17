// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

//! The purpose of this crate is to offer a single source of truth for the definitions of shared
//! constants within the Diem codebase. This is useful because many different components within
//! Diem often require access to global constant definitions (e.g., Diem Safety Rules,
//! the Key Manager, and Secure Storage). To avoid duplicating these definitions across crates
//! (and better allow these constants to be updated in a single location), we define them here.
#![forbid(unsafe_code)]

pub const NODE_HOME: &str = ".0L/";
pub const PROOF_OF_WORK_PREIMAGE: &str = "pow_preimage";
pub const PROOF_OF_WORK_PROOF: &str = "pow_proof";
pub const ACCOUNT_PROFILE: &str = "account_profile";
pub const SALT_0L: &str = "0L";
pub const SOURCE_DIR: &str = "libra/";
pub const GENESIS_VDF_SECURITY_PARAM: u64 = 512;

/// Filename for 0L configs
pub const CONFIG_FILE: &str = "0L.toml";
pub const DEFAULT_VAL_PORT: u64 = 6180;
pub const DEFAULT_VFN_PORT: u64 = 6179;
pub const DEFAULT_PUB_PORT: u64 = 6178;

// TODO: make this lazy static.
/// Switch settings between production and testing
pub fn genesis_delay_difficulty() -> u64 {
    let node_env = match std::env::var("NODE_ENV") {
        Ok(val) => val,
        _ => "prod".to_string() // default to "prod" if not set
    };
    // test settings need to be set explicitly
    if node_env == "test" {
        return 100 // difficulty for test suites and on local for debugging purposes.
    }
    return 120_000_000
}