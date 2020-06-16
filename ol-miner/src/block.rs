//! Proof block datastructure

use hex::{decode, encode};
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};

/// Data structure and serialization of OL delay proof.
#[derive(Serialize, Deserialize)]
pub struct Block {
    /// Block Height
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
    //! Functions for generating the OL delay proof and writing data to file system.
    use super::Block;
    use crate::config::*;
    use crate::delay::*;
    use crate::prelude::*;
    use glob::glob;
    use libra_crypto::hash::HashValue;
    use std::{fs, io::Write, path::Path, path::PathBuf};

    /// writes a JSON file with the vdf proof, ordered by a blockheight

    pub fn mine_genesis(config: &OlMinerConfig) {
        let preimage = config.genesis_preimage();
        let block = Block {
            height: 0u64,
            // note: do_delay() sigature is (challenge, delay difficulty).
            // note: trait serializes data field.
            data: delay::do_delay(&preimage, config.chain_info.block_size),
        };
        //TODO: check for overwriting file...
        let block_dir_buf = Path::new(&config.chain_info.block_dir).to_path_buf();

        write_json(&block, block_dir_buf)
    }
    /// Mine one block
    pub fn mine_once(config: &OlMinerConfig) -> u64 {
        let block_dir = Path::new(&config.chain_info.block_dir);

        let (_current_block_number, current_block_path) = parse_block_height(block_dir);
        // If there are files in path, continue mining.
        if let Some(max_block_path) = current_block_path {
            // current_block_path is Option type, check if destructures to Some.
            let block_file = fs::read_to_string(max_block_path)
                .expect("Could not read latest block file in path");

            let latest_block: Block =
                serde_json::from_str(&block_file).expect("could not deserialize latest block");

            let preimage = HashValue::sha3_256_of(&latest_block.data).to_vec();
            // Otherwise this is the first time the app is run, and it needs a genesis preimage, which comes from configs.
            let height = latest_block.height + 1;
            // TODO: cleanup this duplication with mine_genesis_once?
            let block = Block {
                height,
                // note: do_delay() sigature is (challenge, delay difficulty).
                // note: trait serializes data field.
                data: delay::do_delay(&preimage, config.chain_info.block_size),
            };

            let block_dir_buf = block_dir.to_path_buf();
            write_json(&block, block_dir_buf);
            height
        } else {
            println!("No files found in {:?}", block_dir);
            0u64
        }
    }
    /// Write block to file
    pub fn write_block(config: &OlMinerConfig) {
        // get the location of this miner's blocks
        let blocks_dir = Path::new(&config.chain_info.block_dir);
        let (current_block_number, _current_block_path) = parse_block_height(blocks_dir);

        // If there are files in path, continue mining.
        if current_block_number == 0 {
            mine_genesis(config);
            status_ok!("Generating Genesis Proof", "0");
        }

        loop {
            let blockheight = mine_once(&config);
            status_ok!("Generating Proof for block:", blockheight.to_string());
            // current_block_path is Option type, check if destructures to Some.
        }

        // if Some(current_block_path) = current_block_path
        // set the preimages (or 'challenge') of this sequence for the OL proof.
        // the preimage is a hash of the previous block's proof.
        // in the case of the first block, use the unhashed config.gen_preimage()
        // let mut preimage = {
        //     // In this case the app is picking up where it previously left off.
        //     // If there is a previous block (max_block_path), use the proof (.data) as the preimage for next block.
        //     if let Some(max_block_path) = current_block_path{ // current_block_path is Option type, check if destructures to Some.
        //         let block_file =fs::read_to_string(max_block_path)
        //         .expect("Could not read latest block");
        //
        //         let latest_block: Block = serde_json::from_str(&block_file)
        //         .expect("could not deserialize latest block");
        //
        //         HashValue::sha3_256_of(&latest_block.data).to_vec()
        //     // Otherwise this is the first time the app is run, and it needs a genesis preimage, which comes from configs.
        //     }else{
        //         config.genesis_preimage() // was a hash, shouldn't be on the first preimage.
        //         //HashValue::sha3_256_of(&config.gen_preimage()).to_vec()
        //     }
        // };

        // generate new blocks continuosly using the previous block's proof as the input to the next.
    }

    fn write_json(block: &Block, blocks_dir: PathBuf) {
        if !&blocks_dir.exists() {
            // first run, create the directory if there is none, or if the user changed the configs.
            // note: user may have blocks but they are in a different directory than what ol_miner.toml says.
            fs::create_dir(&blocks_dir).unwrap();
        };
        // Write the file.
        let mut latest_block_path = blocks_dir;
        latest_block_path.push(format!("block_{}.json", block.height));
        //println!("{:?}", &latest_block_path);
        let mut file = fs::File::create(&latest_block_path).unwrap();
        file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
            .expect("Could not write block");
    }

    // parse the existing blocks in the miner's path. This function receives any path.
    // Note: the path is configured in ol_miner.toml which abscissa Configurable parses, see commands.rs.
    fn parse_block_height(blocks_dir: &Path) -> (u64, Option<PathBuf>) {
        let mut max_block = 0u64;
        let mut max_block_path = None;

        // iterate through all json files in the directory.
        for entry in glob(&format!("{}/block_*.json", blocks_dir.display()))
            .expect("Failed to read glob pattern")
        {
            if let Ok(entry) = entry {
                if let Some(stem) = entry.file_stem() {
                    if let Some(stem_string) = stem.to_str() {
                        let blocknumber = stem_string.replace("block_", ""); 
                            // TODO: Alternatively rely on the json data field 'height' insead of file name.
                            let blocknumber = blocknumber.parse::<u64>().unwrap();
                            if blocknumber >= max_block {
                                max_block = blocknumber;
                                max_block_path = Some(entry);
                            }
                        
                    }
                }
            }
        }
        (max_block, max_block_path)
    }

    /* ////////////// */
    /* / Unit tests / */
    /* ////////////// */

    // TODO: Tests generate side-effects. For now run sequentially with `cargo test -- --test-threads 1`
    #[allow(dead_code)]
    fn test_helper_clear_block_dir(blocks_dir: &Path) {
        // delete the temporary test file and directory.
        // remove_dir_all is scary: be careful with this.
        fs::remove_dir_all(blocks_dir).unwrap();
    }

    #[test]
    fn test_mine_genesis() {
        // if no file is found, the block height is 0
        //let blocks_dir = Path::new("./test_blocks");
        let mock_configs = OlMinerConfig {
            profile: Profile {
                public_key: "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
                    .to_owned(),
                statement: "protests rage across America".to_owned(),
            },
            chain_info: ChainInfo {
                chain_id: "Ol testnet".to_owned(),
                block_size: 100.to_owned(),
                block_dir: "test_blocks".to_owned(),
            },
        };

        let blocks_dir = Path::new(&mock_configs.chain_info.block_dir);

        mine_genesis(&mock_configs);

        // let latest_block_path = &mock_configs.chain_info.block_dir.to_string().push(format!("block_0.json"));

        let block_file =
            fs::read_to_string("./test_blocks/block_0.json").expect("Could not read latest block");

        let latest_block: Block =
            serde_json::from_str(&block_file).expect("could not deserialize latest block");

        // Test the file is read, and blockheight is 0
        assert_eq!(latest_block.height, 0, "test");

        // Test the expected proof is writtent to file correctly.
        let correct_proof = "003cfa95da49672d3bc5a6063e75ec9056596675c66ec2ef7d281e2ac105fdfce389ba211b45441bd35143352475a90f1c90363c5a98febd607c625196edcf695ff4b84703c5e6b73ff4c868290b9278b945550a57986b85afcfc0dee6b1ab8517f69e15e3b585da117e2da761c7ae3524b7a378dacf72e0ae53a4b62d07b3e73cffc63b085610b551ac9ca3eede482935e69c3e774a7c12db2baa865d3c31a4b21b9ba987fde31f9779ea0530d1f10a59550e7ae243167d6eafb4cccea6d9e01d5f7433d7a79a632dcdc16d279572c3e85236981ae7c2b8b450a0e1fb61bdda16db278dc85a39b7e805be5378578cc445315b618b702aaa1664fa3259252f93d18f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
        assert_eq!(hex::encode(&latest_block.data), correct_proof, "test");

        test_helper_clear_block_dir(blocks_dir);
    }

    #[test]
    fn test_mine_once() {
        // if no file is found, the block height is 0
        //let blocks_dir = Path::new("./test_blocks");
        let mock_configs = OlMinerConfig {
            profile: Profile {
                public_key: "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
                    .to_owned(),
                statement: "protests rage across America".to_owned(),
            },
            chain_info: ChainInfo {
                chain_id: "Ol testnet".to_owned(),
                block_size: 100.to_owned(),
                block_dir: "test_blocks".to_owned(),
            },
        };

        let mock_previous_proof = hex::decode("003cfa95da49672d3bc5a6063e75ec9056596675c66ec2ef7d281e2ac105fdfce389ba211b45441bd35143352475a90f1c90363c5a98febd607c625196edcf695ff4b84703c5e6b73ff4c868290b9278b945550a57986b85afcfc0dee6b1ab8517f69e15e3b585da117e2da761c7ae3524b7a378dacf72e0ae53a4b62d07b3e73cffc63b085610b551ac9ca3eede482935e69c3e774a7c12db2baa865d3c31a4b21b9ba987fde31f9779ea0530d1f10a59550e7ae243167d6eafb4cccea6d9e01d5f7433d7a79a632dcdc16d279572c3e85236981ae7c2b8b450a0e1fb61bdda16db278dc85a39b7e805be5378578cc445315b618b702aaa1664fa3259252f93d18f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

        let mock_block = Block {
            /// Block Height
            height: 0,
            data: mock_previous_proof,
        };

        let blocks_dir = Path::new(&mock_configs.chain_info.block_dir);
        write_json(&mock_block, blocks_dir.to_path_buf());

        // confirm this mock was written to systems.
        // let block_file =fs::read_to_string("./test_blocks/block_0.json")
        // .expect("Could not read latest block");
        // let latest_block: Block = serde_json::from_str(&block_file)
        // .expect("could not deserialize latest block");
        // // Test the file is read, and blockheight is 0
        // assert_eq!(latest_block.height, 0, "test");

        mine_once(&mock_configs);

        // confirm this mock was written to systems.
        let block_file =
            fs::read_to_string("./test_blocks/block_1.json").expect("Could not read latest block");
        let latest_block: Block =
            serde_json::from_str(&block_file).expect("could not deserialize latest block");
        // Test the file is read, and blockheight is 0
        assert_eq!(latest_block.height, 1, "Not the droid you are looking for.");

        // Test the expected proof is writtent to file correctly.
        let correct_proof = "001349856a8aa8aa05b584826c30b930c04cbe86f0223de0a51a1e119fe0da7b3009175ff30128c5d21ad98be259ea47a11d26478c8b38e1433fa567cd66599c97f23a0d4a1fef80e8d0e3e7ccaf53b78771f1e708ae7f33dd1e5541bd023a1dcaf3e8cd3d24186680b8ffc42a21232c606c09b85b1491b066b3b88fd0c15c4f3effee4708f9061c2df21f77bc5acc04a405e8c6df92b451ba289a2e1524d45e5d9f543c5e0c3437ff2e99e5b847c67a81815aa0c172e30f1caf80de5bda5d4d81c1a6292c1d78754d4ed02c62b0f6bfe5d8cc48442674850aef17863f37fbf9c69c6c9a7325c9c4bf38e66963ede62798b541ac2c4469152bae1157c2831f5a576b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
        assert_eq!(
            hex::encode(&latest_block.data),
            correct_proof,
            "Not the proof of the new block created"
        );

        test_helper_clear_block_dir(blocks_dir);
    }

    #[test]
    fn test_parse_no_files() {
        // if no file is found, the block height is 0
        let blocks_dir = Path::new(".");
        assert_eq!(parse_block_height(blocks_dir).0, 0);
    }

    #[test]
    fn test_parse_one_file() {
        // create a mock file temporarily in ./test_blocks with height 33
        let current_block_number = 33;
        let block = Block {
            height: current_block_number,
            // note: do_delay() sigature is (challenge, delay difficulty).
            // note: trait serializes data field.
            data: Vec::new(),
        };

        // write the mock data temporarilty
        let blocks_dir = Path::new("./test_blocks");
        fs::create_dir(blocks_dir).unwrap();
        let mut latest_block_path = blocks_dir.to_path_buf();
        latest_block_path.push(format!("block_{}.json", current_block_number));
        let mut file = fs::File::create(&latest_block_path).unwrap();
        file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
            .expect("Could not write block");

        // block height
        assert_eq!(parse_block_height(blocks_dir).0, 33);

        test_helper_clear_block_dir(blocks_dir)
    }
}
