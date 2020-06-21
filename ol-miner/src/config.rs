//! OlMiner Config
//!
//! See instructions in `commands.rs` to specify the path to your
//! application's configuration file and/or command-line options
//! for specifying it.

use byteorder::{LittleEndian, WriteBytesExt};
use serde::{Deserialize, Serialize};

/// OlMiner Configuration
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct OlMinerConfig {
    /// User Profile
    pub profile: Profile,
    /// Chain Info for all users
    pub chain_info: ChainInfo,
}

impl OlMinerConfig {
    /// Format the config file data into a fixed byte structure for easy parsing in Move/other languages
    pub fn genesis_preimage(&self) -> Vec<u8> {
        let mut preimage: Vec<u8> = vec![];

        let mut padded_key_bytes = match hex::decode(self.profile.public_key.clone()) {
            Err(x) => panic!("Invalid OL Key{}", x),
            Ok(key_bytes) => {
                if key_bytes.len() != 32 {
                    panic!("Expected a 32 byte OL Key . Got{}", key_bytes.len());
                }
                key_bytes
            }
        };

        preimage.append(&mut padded_key_bytes);

        let mut padded_chain_id_bytes = {
            let mut chain_id_bytes = self.chain_info.chain_id.clone().into_bytes();

            match chain_id_bytes.len() {
                d if d > 64 => panic!(
                    "Chain Id is longer than 64 bytes. Got {} bytes",
                    chain_id_bytes.len()
                ),
                d if d < 64 => {
                    let padding_length = 64 - chain_id_bytes.len() as usize;
                    let mut padding_bytes: Vec<u8> = vec![0; padding_length];
                    padding_bytes.append(&mut chain_id_bytes);
                    padding_bytes
                }
                d if d == 64 => chain_id_bytes,
                _ => unreachable!(),
            }
        };

        preimage.append(&mut padded_chain_id_bytes);

        preimage
            .write_u64::<LittleEndian>(crate::application::DELAY_ITERATIONS)
            .unwrap();

        let mut padded_statements_bytes = {
            let mut statement_bytes = self.profile.statement.clone().into_bytes();

            match statement_bytes.len() {
                d if d > 1024 => panic!(
                    "Chain Id is longer than 1024 bytes. Got {} bytes",
                    statement_bytes.len()
                ),
                d if d < 1024 => {
                    let padding_length = 1024 - statement_bytes.len() as usize;
                    let mut padding_bytes: Vec<u8> = vec![0; padding_length];
                    padding_bytes.append(&mut statement_bytes);
                    padding_bytes
                }
                d if d == 1024 => statement_bytes,
                _ => unreachable!(),
            }
        };

        preimage.append(&mut padded_statements_bytes);

        assert!(
            preimage.len()
                == (
                    32 // OL Key
                    +64 // chain_id
                    +8 // iterations/difficulty
                    +1024
                    // statement
                ),
            "preimage is the incorrect size"
        );
        return preimage;
    }
}

/// Default configuration settings.
///
/// Note: if your needs are as simple as below, you can
/// use `#[derive(Default)]` on OlMinerConfig instead.
impl Default for OlMinerConfig {
    fn default() -> Self {
        Self {
            profile: Profile::default(),
            chain_info: ChainInfo::default(),
        }
    }
}
/// Information about the Chain to mined for
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct ChainInfo {
    /// Chain that this work is being committed to
    pub chain_id: String,
    /// Directory to store blocks in
    pub block_dir: String,
}

// TODO: These defaults serving as test fixtures.
impl Default for ChainInfo {
    fn default() -> Self {
        Self {
            chain_id: "Ol testnet".to_owned(),
            block_dir: "blocks".to_owned(),
        }
    }
}
/// Miner profile to commit this work chain to a particular identity
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct Profile {
    ///Miner Public Key for OL Blockchain
    pub public_key: String,
    ///An opportunites for the Miner to argument for his value to the network
    pub statement: String,
}

impl Default for Profile {
    fn default() -> Self {
        Self {
            // TODO: change this public key.
            public_key: "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
                .to_owned(),
            statement: "protests rage across America".to_owned(),
        }
    }
}
