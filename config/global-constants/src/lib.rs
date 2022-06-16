// Copyright (c) The Diem Core Contributors
// SPDX-License-Identifier: Apache-2.0

//! The purpose of this crate is to offer a single source of truth for the definitions of shared
//! constants within the Diem codebase. This is useful because many different components within
//! Diem often require access to global constant definitions (e.g., Diem Safety Rules,
//! the Key Manager, and Secure Storage). To avoid duplicating these definitions across crates
//! (and better allow these constants to be updated in a single location), we define them here.
#![forbid(unsafe_code)]

use std::env;

/// Definitions of global cryptographic keys (e.g., as held in secure storage)
pub const CONSENSUS_KEY: &str = "consensus";
pub const EXECUTION_KEY: &str = "execution";
pub const FULLNODE_NETWORK_KEY: &str = "fullnode_network";
pub const DIEM_ROOT_KEY: &str = "diem_root";
pub const TREASURY_COMPLIANCE_KEY: &str = "treasury_compliance";
pub const OPERATOR_ACCOUNT: &str = "operator_account";
pub const OPERATOR_KEY: &str = "operator";
pub const OWNER_ACCOUNT: &str = "owner_account";
pub const OWNER_KEY: &str = "owner";
pub const VALIDATOR_NETWORK_ADDRESS_KEYS: &str = "validator_network_address_keys";
pub const VALIDATOR_NETWORK_KEY: &str = "validator_network";

/// Definitions of global data items (e.g., as held in secure storage)
pub const SAFETY_DATA: &str = "safety_data";
pub const WAYPOINT: &str = "waypoint";
pub const GENESIS_WAYPOINT: &str = "genesis-waypoint";

//////// 0L ////////
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
    let node_env = match env::var("NODE_ENV") {
        Ok(val) => val,
        _ => "prod".to_string() // default to "prod" if not set
    };
    // test settings need to be set explicitly
    if node_env == "test" {
        return 100 // difficulty for test suites and on local for debugging purposes.
    }
    return 120_000_000
}
