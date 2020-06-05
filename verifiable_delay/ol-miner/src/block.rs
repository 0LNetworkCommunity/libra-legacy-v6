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
    use libra_crypto::hash::HashValue;
    use crate::delay::*;


    // writes a JSON file with the vdf proof, ordered by a blockheight
    pub fn write_block(proof_data: Vec<u8>) {

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
                return (max_block, max_block_path)
            }
        };

        let config = app_config();
        let blocks_dir = Path::new(&config.chain_info.block_dir);
        let (mut current_block_number, current_block_path) = parse_block_height(blocks_dir);

        let mut preimage ={
            // If there is a previous block, use the last block as the preimage.
            // This is the case where the app is picking up where it previously left off.
            if let Some(max_block_path) = current_block_path{
                let block_file =fs::read_to_string(max_block_path)
                .expect("Could not read latest block");

                let latest_block:Block = serde_json::from_str(&block_file)
                .expect("could not deserialize latest block");

                HashValue::sha3_256_of(&latest_block.data).to_vec()
            // Otherwise this is the first time the app is run, and it needs a genesis preimage, which comes from configs.
            }else{
                HashValue::sha3_256_of(&config.gen_preimage()).to_vec()
            }
        };

        loop{
            status_ok!("Generating Proof for block {}",current_block_number.to_string());

            let block = Block {
                height: current_block_number + 1,
                // note: do_delay() sigature is (challenge, delay difficulty)
                data: delay::do_delay(&config.gen_preimage(),config.chain_info.block_size)
            };
            current_block_number +=1;

            // set the preimage for the next loop.
            preimage = HashValue::sha3_256_of(&block.data).to_vec();

            // Write the file.
            // serialize the data
            let mut latest_block_path = blocks_dir.to_path_buf();
            latest_block_path.push(format!("block_{}.json", current_block_number));
            let mut file = fs::File::create(&latest_block_path).unwrap();

            file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
                .expect("Could not write block");

            let config = app_config();
            let blocks_dir = Path::new(&config.chain_info.block_dir);
        }
    }
}
