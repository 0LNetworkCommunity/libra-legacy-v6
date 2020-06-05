//! Proof block datastructure

use hex::{decode, encode};
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};
use std::{fs, io::Write, path::Path, path::PathBuf};
use glob::glob;
// use abscissa_core::{config, Command, FrameworkError, Options, Runnable};

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
    use std::{fs, io::Write, path::Path, path::PathBuf}; //newb q: why is this imported here again?
    use super::Block;
    use crate::prelude::*;
    use libra_crypto::hash::HashValue;
    use crate::delay::*;

    // writes a JSON file with the vdf proof, ordered by a blockheight
    pub fn write_block() {
        // get the location of this miner's blocks
        let config = app_config();
        let blocks_dir = Path::new(&config.chain_info.block_dir);
        let (mut current_block_number, current_block_path) = super::parse_block_height(blocks_dir);

        // create the preimage (or 'challenge') for the VDF proof.
        let mut preimage ={
            // In this case the app is picking up where it previously left off.
            // If there is a previous block (max block), use the data (proof) as the preimage.
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

        // generate new blocks continuosly using the previous block's proof as the input to the next.
        loop{
            status_ok!("Generating Proof for block:",current_block_number.to_string());

            let block = Block {
                height: current_block_number + 1,
                // note: do_delay() sigature is (challenge, delay difficulty).
                // note: trait serializes data field.
                data: delay::do_delay(&preimage,config.chain_info.block_size)
            };
            current_block_number +=1;

            // set the preimage for the next loop.
            preimage = HashValue::sha3_256_of(&block.data).to_vec();

            // Write the file.
            let mut latest_block_path = blocks_dir.to_path_buf();
            latest_block_path.push(format!("block_{}.json", current_block_number));
            let mut file = fs::File::create(&latest_block_path).unwrap();
            file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
                .expect("Could not write block");
        }
    }
}

// parse the existing blocks in the miner's path. This function receives any path.
// Note: the path is configured in ol_miner.toml which abscissa Configurable parses, see commands.rs.
fn parse_block_height (blocks_dir: &Path) -> (u64, Option<PathBuf>) {
    let mut max_block = 0u64;
    let mut max_block_path = None;

    if !blocks_dir.exists() {
        // first run, create the directory if there is none, or if the user changed the configs.
        // note: user may have blocks but they are in a different directory than what ol_miner.toml says.
        fs::create_dir(blocks_dir).unwrap();
    } else {
        // iterate through all json files in the directory.
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
    };
    (max_block, max_block_path)
}

mod unit_tests {
    #[test]
    fn test_parse_no_files() {
        // if no file is found, the block height is 0
        let blocks_dir = super::Path::new(".");
        assert_eq!(super::parse_block_height(blocks_dir).0, 0);
    }

    #[test]
    fn test_parse_one_file() {
        use std::{fs, io::Write, path::Path, path::PathBuf}; //newb q: why is this imported here again?

        let current_block_number = 33;
        let blocks_dir = Path::new("./test_blocks");
        fs::create_dir(blocks_dir).unwrap();

        let block = super::Block {
            height: current_block_number,
            // note: do_delay() sigature is (challenge, delay difficulty).
            // note: trait serializes data field.
            data: Vec::new()
        };

        let mut latest_block_path = blocks_dir.to_path_buf();
        latest_block_path.push(format!("block_{}.json", current_block_number));
        let mut file = fs::File::create(&latest_block_path).unwrap();
        file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
            .expect("Could not write block");


        // if no file is found, the block height is 0
        assert_eq!(super::parse_block_height(blocks_dir).0, 33);
    }



}
