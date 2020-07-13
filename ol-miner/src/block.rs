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
    pub preimage: Vec<u8>,
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
    let s: String = Deserialize::deserialize(deserializer)?;
    // do better hex decoding than this
    decode(s).map_err(D::Error::custom)
}

impl Block {
    pub fn get_genesis_tx_data(path:std::path::PathBuf) -> Result<(String,String),std::io::Error> {


        let mut file = std::fs::File::open(path)?;
        let reader = std::io::BufReader::new(file);
        let block: Block = serde_json::from_reader(reader).expect("Genesis block should deserialize");
        return Ok((hex::encode(block.preimage),hex::encode(block.data)));
    }

    pub fn get_proof(config: &crate::config::OlMinerConfig , height: u64) -> Vec<u8> {

        let blocks_dir = std::path::Path::new(&config.chain_info.block_dir);

        let mut file = std::fs::File::open(format!("{}/block_{}.json",blocks_dir.display(),height)).expect("Could not open block file");
        let reader = std::io::BufReader::new(file);
        let block: Block = serde_json::from_reader(reader).unwrap();

        return block.data.clone();
    }
}

pub mod build_block {
    //! Functions for generating the OL delay proof and writing data to file system.
    use super::Block;
    use crate::config::*;
    use crate::delay::*;
    use crate::error::{Error, ErrorKind};
    use crate::prelude::*;
    use crate::submit_tx::submit_vdf_proof_tx_to_network;
    use glob::glob;
    use libra_crypto::hash::HashValue;
    use libra_types::{account_address::AccountAddress, waypoint::Waypoint};
    use std::time::{Duration, Instant};
    use std::{
        fs,
        io::{BufReader, Write},
        path::Path,
        path::PathBuf,
    };

    /// writes a JSON file with the vdf proof, ordered by a blockheight
    pub fn mine_genesis(config: &OlMinerConfig) {
        let preimage = config.genesis_preimage();
        let mut now = Instant::now();
        let data = do_delay(&preimage, crate::application::DELAY_ITERATIONS);
        let elapsed_secs = now.elapsed().as_secs();
        println!("Delay: {:?} seconds", elapsed_secs);
        let block = Block {
            height: 0u64,
            elapsed_secs,
            // note: do_delay() sigature is (challenge, delay difficulty).
            // note: trait serializes data field.
            preimage,
            data,
        };
        //TODO: check for overwriting file...
        let block_dir_buf = Path::new(&config.chain_info.block_dir).to_path_buf();

        write_json(&block, block_dir_buf)
    }
    /// Mine one block
    pub fn mine_once(config: &OlMinerConfig) -> Result<Block, Error> {
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
            let data = do_delay(&preimage, crate::application::DELAY_ITERATIONS);
            let elapsed_secs = now.elapsed().as_secs();
            println!("Delay: {:?} seconds", elapsed_secs);

            let block = Block {
                height,
                elapsed_secs,
                // note: do_delay() sigature is (challenge, delay difficulty).
                // note: trait serializes data field.
                preimage,
                data: data.clone(), //data: delay::do_delay(&preimage, crate::application::DELAY_ITERATIONS),
            };

            let block_dir_buf = block_dir.to_path_buf();
            write_json(&block, block_dir_buf);
            Ok(block)
        // Err(ErrorKind::Io.context(format!("submit_vdf_proof_tx_to_network {:?}", block_dir)).into())
        } else {
            return Err(ErrorKind::Io
                .context(format!("No files found in {:?}", block_dir))
                .into());
        }
    }
    /// Write block to file
    pub fn mine_and_submit(
        config: &OlMinerConfig,
        mnemonic: String,
        waypoint: Waypoint,
    ) -> Result<(), Error> {
        // get the location of this miner's blocks
        let blocks_dir = Path::new(&config.chain_info.block_dir);
        let (current_block_number, _current_block_path) = parse_block_height(blocks_dir);

        // If there are NO files in path, mine the genesis proof.
        if current_block_number.is_none() {
            status_ok!("Generating Genesis Proof", "0");
            mine_genesis(config);
            status_ok!("Provide this proof to a friend who can submit it", "0");
            std::process::exit(1);
        } else {
            // mine continuously from the last block in the file systems
            loop {
                let block = mine_once(&config)?;
                status_ok!("Generating Proof for block:", block.height.to_string());

                // if parameters for connecting to the network are passed
                // try to submit transactions to network.
                if waypoint.version() >= 0 {
                    if let Some(ref node) = config.chain_info.node {
                        // get preimage
                        submit_vdf_proof_tx_to_network(
                            block.preimage,                       // challenge: Vec<u8>,
                            crate::application::DELAY_ITERATIONS, // difficulty: u64,
                            block.data,                           // proof: Vec<u8>,
                            waypoint,                             // waypoint: Waypoint,
                            mnemonic.to_string(),
                            node.to_string(),
                        ).unwrap();
                        status_ok!("Submitted {}",block.height.to_string());
                    } else {
                        return Err(ErrorKind::Config
                            .context("No Node for submitting transactions")
                            .into());
                    }
                } else {
                    return Err(ErrorKind::Config
                        .context("No Waypoint for client provided")
                        .into());
                }
            }
        }
    }

    /// Submit a block stored in the file system
    pub fn submit_block(
        config: &OlMinerConfig,
        mnemonic: String,
        waypoint: Waypoint,
        height:usize,
    ) -> Result<(), Error> {

        let blocks_dir = Path::new(&config.chain_info.block_dir);

        let mut file = fs::File::open(format!("{}/block_{}.json",blocks_dir.display(),height)).expect("Could not open block file");
        let reader = BufReader::new(file);
        let block: Block = serde_json::from_reader(reader).unwrap();

        if let Some(ref node) = config.chain_info.node {
            // get preimage
            submit_vdf_proof_tx_to_network(
                block.preimage,                       // challenge: Vec<u8>,
                crate::application::DELAY_ITERATIONS, // difficulty: u64,
                block.data,                           // proof: Vec<u8>,
                waypoint,                             // waypoint: Waypoint,
                mnemonic.to_string(),
                node.to_string(),
            ).unwrap();
            status_ok!("Submitted {}",block.height.to_string());
        } else {
            // // TODO (Ping): 1. Catch these errors instead of panic.
            // // 2. Save the latest succesfull tower_height to a local file. LocalMinerState.json
            // // PSEUDOCODE:
            // Struct LocalMinerState {
            //     pubkey: &str,
            //     local_tower_height: u64,
            //     last_succesful_tx_height: u64,
            //     retrying_height: u64, // if there is a resubmission in process, we need to know.
            // }
            // let state: LocalMinerState
            // let mut latest_block_path = blocks_dir;
            // latest_block_path.push(format!("0_LocalMinerState.json"));
            // let mut file = fs::File::create(&latest_block_path).unwrap();
            // file.write_all(serde_json::to_string(&state).unwrap().as_bytes())
            //     .expect("Could not write block");
            // // 2. Resend transactions with a timer, e.g 30 seconds (use an exponential backoff). Stop retrying after 10 times or max_retries.
            // // 2a. Add retrying_height to LocalMinerState. OR clear it if Stop retrying.
            // for i in max_retries {
            // submit_vdf_proof_tx_to_network(xxxxxx)
            // }

            return Err(ErrorKind::Config
                .context("No Node for submitting transactions")
                .into());
        }

    Ok(())
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
    fn parse_block_height(blocks_dir: &Path) -> (Option<u64>, Option<PathBuf>) {
        let mut max_block: Option<u64> = None;
        let mut max_block_path = None;

        // iterate through all json files in the directory.
        for entry in glob(&format!("{}/block_*.json", blocks_dir.display()))
            .expect("Failed to read glob pattern")
        {
            if let Ok(entry) = entry {
                let mut file = fs::File::open(&entry).expect("Could not open block file");
                let reader = BufReader::new(file);
                let block: Block = serde_json::from_reader(reader).unwrap();
                let blocknumber = block.height;
                if max_block.is_none() {
                    max_block = Some(blocknumber);
                    max_block_path = Some(entry);
                } else {
                    if blocknumber > max_block.unwrap() {
                        max_block = Some(blocknumber);
                        max_block_path = Some(entry);
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
        if blocks_dir.exists() {
            fs::remove_dir_all(blocks_dir).unwrap();
        }
    }

    #[test]
    fn test_mine_genesis() {
        // if no file is found, the block height is 0
        //let blocks_dir = Path::new("./test_blocks");
        let configs_fixture = OlMinerConfig {
            profile: Profile {
                public_key: "5ffd9856978b5020be7f72339e41a401".to_owned(),
                statement: "protests rage across America".to_owned(),
            },
            chain_info: ChainInfo {
                chain_id: "Ol testnet".to_owned(),
                block_dir: "test_blocks_temp_1".to_owned(), //  path should be unique for concurrent tests.
                base_waypoint: "None".to_owned(),
                node: None,
            },
        };

        // mine
        mine_genesis(&configs_fixture);

        // read file
        let blocks_dir = Path::new(&configs_fixture.chain_info.block_dir);

        let block_file =
            // TODO: make this work: let latest_block_path = &configs_fixture.chain_info.block_dir.to_string().push(format!("block_0.json"));
            fs::read_to_string("./test_blocks_temp_1/block_0.json").expect("Could not read latest block");

        let latest_block: Block =
            serde_json::from_str(&block_file).expect("could not deserialize latest block");

        // Test the file is read, and blockheight is 0
        assert_eq!(latest_block.height, 0, "test");

        // Test the expected proof is writtent to file correctly.
        let correct_proof = "0004c4f5a4c600050c67a3c8a87b8541c1be136b9565966ff6366a8670ea138f2c24718bbbafbb317ae49e83ab449deaad5fe6e8ae44c3ec13d94021f74cb22561eeb820ca8324e7fd49e27fc5b19111928c8a559411cf4a00565e975a05ee244dae8676803a2b4b57193039be79e23010ef97edba9060ef463f44061889f78bae5c4b1ecc2a27bbe9706bdda00d1de2487d6ffb6cd19cd7f562bd0b6cd78ab0b470da59135899a0233e2cca5c37839a9ea1470c0dd349a783b62fc882c3011a9a3f58d51d899855427255ebd7c92bf68fc863790ef71750a639614d9263b0731596fe435d834be77d0bc6a3c8a6de092219ab40ada39aaf59b83c6b5739c11650fffca5f0afcfb2ce7e34add26bd634ed9fcefa1dcf61547f5aa3a2b593a47622fd12c3310f5697fff9504ef3b877e927aebd15c5e8fe262c1efd5cb57e0c6c0f8e604345ef0d471ef51b57fcbe30a6744fe84f41409b003c751d6e408a94bcfb283f23b6090c98f4376c8e11c0defbbedce6146415ac19fe9e96f5a46e5100120628486742921ecb8741ccc811fff53f3e2fe85c92f7e7cf8cc34b1cad0404de0b378401f5a585753101be0c744f6c7eb06c3829f39382aaeadfc148dd3cfd73f5092b932828849918ceff4d72293a96315dd02da6754e71040a458e7e9088ef75cce75cb706b7cca022a019bea71a4bfab226972335724e566c5be8aca3230c5300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
        assert_eq!(hex::encode(&latest_block.data), correct_proof, "test");

        // test_helper_clear_block_dir(blocks_dir);
    }

    #[test]
    fn test_mine_once() {
        // if no file is found, the block height is 0
        //let blocks_dir = Path::new("./test_blocks");

        let configs_fixture = OlMinerConfig {
            profile: Profile {
                public_key: "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
                    .to_owned(),
                statement: "protests rage across America".to_owned(),
            },
            chain_info: ChainInfo {
                chain_id: "Ol testnet".to_owned(),
                block_dir: "test_blocks_temp_2".to_owned(),
                base_waypoint: "None".to_owned(),
                node: None,
            },
        };

        let blocks_dir = Path::new(&configs_fixture.chain_info.block_dir);
        // Clear at start. Clearing at end can pollute the path when tests fail.
        test_helper_clear_block_dir(blocks_dir);

        let fixture_previous_proof = hex::decode("005f6371e754d98dd0230d051fce8462cd64257717e988ffbff95ed9b84d130b6ee1a97bff4eedc4cd28721b1f78358f8ce1a7f0b0a2e75a4740af0f328414daad2b3c205a82bbd334b7fc9ae70b8628fb7f02247b0c6416a25662202d8c63de116876b8fb575d2cffae9ea48bd511142ea5f737a9278106093e143f8c6b8d0dd13804ca601310c059ce1db3fd58eb3068dde0658a4e330cc8e5934ab2fe41e4b757e69b2edce436ceac8b0e801b66fcf453f36a4300c286039143e36dfbc100c5d0f40cd7d74a9421b3b8e547de5e82797f365c5524d35813820de538c6ef2ef980995d071a6fa26826335626f1b1b4ee256b67603b1b7df338b4607137bd433affba8a94c6f234defb09ef6d5cc697a73a5b57caf9ef8992ccf4ab35affd997c8294be37b1cfae93fe89781062cc50435fadc9be416279e02ba2eddbdbb659fbc60d8eb76f2bed5adf4a26c6a81f39eea20d65b81e91e52a38eab6229cb975bc75f46dfa65ada848234dd362aa086091fd95a0df21cb2a59d34b155a5105aef71c1a6c7ef340194f1ea3697ec59feb5ce3ea67a00149b36af5de44d2c3863e580267cffee49b9f5ba20104d65f5333c05839e5877006de9dd4c203953cc103faf82fb50a76856333fbe5b36fb6ea76123c343f2bd56192d5c300e17699659cea5acf5991643ba05fef2e399ca68d027a74c6c7c908c03adfa1b7f5c56d163ee37b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

        let fixture_block = Block {
            /// Block Height
            height: 0u64,
            elapsed_secs: 0u64,
            preimage: Vec::new(),
            data: fixture_previous_proof,
        };

        write_json(&fixture_block, blocks_dir.to_path_buf());

        // confirm this fixture was written to systems.
        // let block_file =fs::read_to_string("./test_blocks/block_0.json")
        // .expect("Could not read latest block");
        // let latest_block: Block = serde_json::from_str(&block_file)
        // .expect("could not deserialize latest block");
        // // Test the file is read, and blockheight is 0
        // assert_eq!(latest_block.height, 0, "test");

        mine_once(&configs_fixture).unwrap();

        // mine_once(&configs_fixture, "test mnemonic", Waypoint::default(), "".to_string() ).unwrap();

        // confirm this file was written to disk.
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
        assert_eq!(parse_block_height(blocks_dir).0, None);
    }

    #[test]
    fn test_parse_one_file() {
        // create a file temporarily in ./test_blocks with height 33
        let current_block_number = 33;
        let block = Block {
            height: current_block_number,
            elapsed_secs: 0u64,
            preimage: Vec::new(),
            // note: do_delay() sigature is (challenge, delay difficulty).
            // note: trait serializes data field.
            data: Vec::new(),
        };

        // write the file temporarilty
        let blocks_dir = Path::new("./test_blocks_temp_3");
        // Clear at start. Clearing at end can pollute the path when tests fail.
        test_helper_clear_block_dir(blocks_dir);

        fs::create_dir(blocks_dir).unwrap();
        let mut latest_block_path = blocks_dir.to_path_buf();
        latest_block_path.push(format!("block_{}.json", current_block_number));
        let mut file = fs::File::create(&latest_block_path).unwrap();
        file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
            .expect("Could not write block");

        // block height
        assert_eq!(parse_block_height(blocks_dir).0, Some(33));

        test_helper_clear_block_dir(blocks_dir)
    }
}
