//! Proof block datastructure

use hex::{decode, encode};
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};

/// Data structure and serialization of OL delay proof.
#[derive(Serialize, Deserialize)]
pub struct Block {
    /// Block Height
    pub height: u64,
    pub elapsed_secs: u64,
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
    use std::time::{Duration, Instant};

    /// writes a JSON file with the vdf proof, ordered by a blockheight
    pub fn mine_genesis(config: &OlMinerConfig) {
        let preimage = config.genesis_preimage();
        let mut now = Instant::now();
        let data = delay::do_delay(&preimage, crate::application::DELAY_ITERATIONS);
        let elapsed_secs = now.elapsed().as_secs();
        println!("Delay: {:?}", elapsed_secs);

        let block = Block {
            height: 0u64,
            elapsed_secs,
            // note: do_delay() sigature is (challenge, delay difficulty).
            // note: trait serializes data field.
            data
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

            let mut now = Instant::now();
            let data = delay::do_delay(&preimage, crate::application::DELAY_ITERATIONS);
            let elapsed_secs = now.elapsed().as_secs();
            println!("Delay: {:?}", elapsed_secs);

            let block = Block {
                height,
                elapsed_secs,
                // note: do_delay() sigature is (challenge, delay difficulty).
                // note: trait serializes data field.
                data //data: delay::do_delay(&preimage, crate::application::DELAY_ITERATIONS),
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
                block_dir: "test_blocks_temp_1".to_owned(), //  path should be unique for concurrent tests.
            },
        };

        // mine
        mine_genesis(&mock_configs);

        // read file
        let blocks_dir = Path::new(&mock_configs.chain_info.block_dir);

        let block_file =
            // TODO: make this work: let latest_block_path = &mock_configs.chain_info.block_dir.to_string().push(format!("block_0.json"));
            fs::read_to_string("./test_blocks_temp_1/block_0.json").expect("Could not read latest block");

        let latest_block: Block =
            serde_json::from_str(&block_file).expect("could not deserialize latest block");

        // Test the file is read, and blockheight is 0
        assert_eq!(latest_block.height, 0, "test");

        // Test the expected proof is writtent to file correctly.
        let correct_proof = "005f6371e754d98dd0230d051fce8462cd64257717e988ffbff95ed9b84d130b6ee1a97bff4eedc4cd28721b1f78358f8ce1a7f0b0a2e75a4740af0f328414daad2b3c205a82bbd334b7fc9ae70b8628fb7f02247b0c6416a25662202d8c63de116876b8fb575d2cffae9ea48bd511142ea5f737a9278106093e143f8c6b8d0dd13804ca601310c059ce1db3fd58eb3068dde0658a4e330cc8e5934ab2fe41e4b757e69b2edce436ceac8b0e801b66fcf453f36a4300c286039143e36dfbc100c5d0f40cd7d74a9421b3b8e547de5e82797f365c5524d35813820de538c6ef2ef980995d071a6fa26826335626f1b1b4ee256b67603b1b7df338b4607137bd433affba8a94c6f234defb09ef6d5cc697a73a5b57caf9ef8992ccf4ab35affd997c8294be37b1cfae93fe89781062cc50435fadc9be416279e02ba2eddbdbb659fbc60d8eb76f2bed5adf4a26c6a81f39eea20d65b81e91e52a38eab6229cb975bc75f46dfa65ada848234dd362aa086091fd95a0df21cb2a59d34b155a5105aef71c1a6c7ef340194f1ea3697ec59feb5ce3ea67a00149b36af5de44d2c3863e580267cffee49b9f5ba20104d65f5333c05839e5877006de9dd4c203953cc103faf82fb50a76856333fbe5b36fb6ea76123c343f2bd56192d5c300e17699659cea5acf5991643ba05fef2e399ca68d027a74c6c7c908c03adfa1b7f5c56d163ee37b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
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
                block_dir: "test_blocks_temp_2".to_owned(),
            },
        };

        let mock_previous_proof = hex::decode("005f6371e754d98dd0230d051fce8462cd64257717e988ffbff95ed9b84d130b6ee1a97bff4eedc4cd28721b1f78358f8ce1a7f0b0a2e75a4740af0f328414daad2b3c205a82bbd334b7fc9ae70b8628fb7f02247b0c6416a25662202d8c63de116876b8fb575d2cffae9ea48bd511142ea5f737a9278106093e143f8c6b8d0dd13804ca601310c059ce1db3fd58eb3068dde0658a4e330cc8e5934ab2fe41e4b757e69b2edce436ceac8b0e801b66fcf453f36a4300c286039143e36dfbc100c5d0f40cd7d74a9421b3b8e547de5e82797f365c5524d35813820de538c6ef2ef980995d071a6fa26826335626f1b1b4ee256b67603b1b7df338b4607137bd433affba8a94c6f234defb09ef6d5cc697a73a5b57caf9ef8992ccf4ab35affd997c8294be37b1cfae93fe89781062cc50435fadc9be416279e02ba2eddbdbb659fbc60d8eb76f2bed5adf4a26c6a81f39eea20d65b81e91e52a38eab6229cb975bc75f46dfa65ada848234dd362aa086091fd95a0df21cb2a59d34b155a5105aef71c1a6c7ef340194f1ea3697ec59feb5ce3ea67a00149b36af5de44d2c3863e580267cffee49b9f5ba20104d65f5333c05839e5877006de9dd4c203953cc103faf82fb50a76856333fbe5b36fb6ea76123c343f2bd56192d5c300e17699659cea5acf5991643ba05fef2e399ca68d027a74c6c7c908c03adfa1b7f5c56d163ee37b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

        let mock_block = Block {
            /// Block Height
            height: 0u64,
            elapsed_secs: 0u64,
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
        let block_file = fs::read_to_string("./test_blocks_temp_2/block_1.json")
            .expect("Could not read latest block");
        let latest_block: Block =
            serde_json::from_str(&block_file).expect("could not deserialize latest block");
        // Test the file is read, and blockheight is 0
        assert_eq!(latest_block.height, 1, "Not the droid you are looking for.");

        // Test the expected proof is writtent to file correctly.
        let correct_proof = "0054a77c688865bd02300dce80911cf281df2ade94ba116a789f217dacfb4f44548a973630c3922a2fa339707b2af8ba461459c776d4f8c57da0f6f22a2104e9b6173b03f6382b6a1141a540a7c29b5d87fc988056f4e6d5124359ac8972f77e7f47a60cef1a2bde3c30f3c1ae87da6cd026f81388a411530005e935b3f7f56120d558b7191da800bceacd04069be03730c064c6d645d59ba4cd58d78462ac5e5da40bbba3110b0debc05495fd26da9aed13e60cf2680faadf9bcd6a0cc4a7178115a485584a2f5fed592a707626d164bd73dbfa8ee33de14cbf8f5bf5e812fc0586911c430715b34aafede3195256ba9bf9463a8bbc755c145dda4f315c9fa5bf0028bda8c949ad43ee742023b8d1cae3beb40b3d12faf33082d600462b2cc7df300a8aca87f847668c487c337ddedf3355635def7387e40edf70cbe811af2ca9d2a96ce6b27335203314619e88dcaa5f934ed6b7b6a6530c2cf36330390937901041362522f97a38c8265c67e7d808377c7623213c6aa4cf60926793298a2dead8ebeaa98c0a5bb30735682f9cf6df4ea468fba4243488b0f4e849149b059689adef603b5564be2a891fdadef82667017e4c8a7560e2d72971049b6e5640fffb86895f096b10611f585d1302339808bf6965195afe9cf77e8c0597a6e252216d63533d739b007ec19847cbf77d99a7fc5d8e66e2d000a16498cdd2cd9f437415d900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
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
            elapsed_secs: 0u64,
            // note: do_delay() sigature is (challenge, delay difficulty).
            // note: trait serializes data field.
            data: Vec::new(),
        };

        // write the mock data temporarilty
        let blocks_dir = Path::new("./test_blocks_temp_3");
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
