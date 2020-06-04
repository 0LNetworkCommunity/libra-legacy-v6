//! Proof block datastructure

use hex::{decode, encode};
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};
use abscissa_core::{config, Command, FrameworkError, Options, Runnable};

#[derive(Serialize, Deserialize)]
pub struct Block {
    ///Block Height
    pub height: u64,
    /// VDF Output
    #[serde(serialize_with = "as_hex", deserialize_with = "from_hex")]
    pub data: Vec<u8>,
}

fn as_hex<S>(data: &[u8], serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
{
    serializer.serialize_str(&encode(data))
}

fn from_hex<'de, D>(deserializer: D) -> Result<Vec<u8>, D::Error>
where
    D: Deserializer<'de>,
{
    let s: &str = Deserialize::deserialize(deserializer)?;
    // do better hex decoding than this
    decode(s).map_err(D::Error::custom)
}

pub mod build_block {
    use glob::glob;
    use std::{fs, io::Write, path::Path, path::PathBuf};
    use super::Block;
    use crate::prelude::*;

    // writes a JSON file with the vdf proof, ordered by a blockheight
    pub fn write_block(proof_data: Vec<u8>) {
        let config = app_config();
        let blocks_dir = Path::new(&config.chain_info.block_dir);

        // parse the existing blocks in the app directory. It's a config in ol_miner.toml
        fn parse_block_height (blocks_dir: &Path) -> (u64, Option<PathBuf>) {
            if !blocks_dir.exists() {
                fs::create_dir(blocks_dir).unwrap();
                (0u64, None)
            } else {
                let mut max_block = 0u64;
                let mut max_block_path = None;
                for entry in glob(&format!("{}/block_*.json", blocks_dir.display()))
                    .expect("Failed to read glob pattern")
                {
                    if let Ok(entry) = entry {
                        if let Some(stem) = entry.file_stem() {
                            if let Some(stem_string) = stem.to_str() {
                                if let Some(blocknumber) = stem_string.strip_prefix("block_") {
                                    let blocknumber = blocknumber.parse::<u64>().unwrap();
                                    if blocknumber > max_block {
                                        max_block = blocknumber;
                                        max_block_path = Some(entry);
                                    }
                                }
                            }
                        }
                    }
                }
                (max_block, max_block_path)
            }
        };

        // Write the file.
        // serialize the data
        let new_height = parse_block_height(blocks_dir).0 + 1;
        let block = Block {
            height: new_height,
            data: proof_data,
        };
        // save a .json document
        let mut latest_block_path = blocks_dir.to_path_buf();
        latest_block_path.push(format!("block_{}.json", new_height));
        let mut file = fs::File::create(&latest_block_path).unwrap();
        file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
            .unwrap();
    }
}
