//! Proof block datastructure

use hex::{decode, encode};
use serde::{de::Error, Deserialize, Deserializer, Serialize, Serializer};
/// Data structure and serialization of 0L delay proof.
#[derive(Serialize, Deserialize)]
pub struct Block {
    /// Block Height
    pub height: u64,
    /// Elapsed Time in seconds
    pub elapsed_secs: u64,
    /// VDF input preimage. AKA challenge
    #[serde(serialize_with = "as_hex", deserialize_with = "from_hex")]
    pub preimage: Vec<u8>,
    /// Data for Block
    #[serde(serialize_with = "as_hex", deserialize_with = "from_hex")]
    /// VDF proof. AKA solution
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

    /// Extract the preimage and proof from a genesis proof block_0.json
    pub fn get_genesis_tx_data(path: &std::path::PathBuf) -> Result<(Vec<u8>,Vec<u8>),std::io::Error> {


        let file = std::fs::File::open(path)?;
        let reader = std::io::BufReader::new(file);
        let block: Block = serde_json::from_reader(reader).expect("Genesis block should deserialize");
        return Ok((block.preimage, block.data));
    }

    // /// Extract the proof/solution from a block.
    // pub fn get_proof(config: &crate::config::OlMinerConfig , height: u64) -> Vec<u8> {

    //     let blocks_dir = std::path::Path::new(&config.chain_info.block_dir);

    //     let file = std::fs::File::open(format!("{}/block_{}.json",blocks_dir.display(),height)).expect("Could not open block file");
    //     let reader = std::io::BufReader::new(file);
    //     let block: Block = serde_json::from_reader(reader).unwrap();

    //     return block.data.clone();
    // }
}

pub mod build_block {
    //! Functions for generating the 0L delay proof and writing data to file system.
    use super::Block;
    use crate::config::*;
    use crate::delay::*;
    use crate::error::{Error, ErrorKind};
    use crate::prelude::*;
    use crate::submit_tx::{submit_tx, TxParams, eval_tx_status};
    use glob::glob;
    use libra_crypto::hash::HashValue;
    use std::{
        fs,
        io::{BufReader, Write},
        path::PathBuf,
        time::Instant,
    };

    /// writes a JSON file with the vdf proof, ordered by a blockheight
    pub fn mine_genesis(config: &OlMinerConfig) {
        let preimage = config.genesis_preimage();
        let now = Instant::now();
        let data = do_delay(&preimage);
        let elapsed_secs = now.elapsed().as_secs();
        println!("Delay: {:?} seconds", elapsed_secs);
        let block = Block {
            height: 0u64,
            elapsed_secs,
            preimage,
            data,
        };
        //TODO: check for overwriting file...
        write_json(&block, &config.get_block_dir());
    }
    /// Mine one block
    pub fn mine_once(config: &OlMinerConfig) -> Result<Block, Error> {

        let (_current_block_number, current_block_path) = parse_block_height(&config.get_block_dir() );
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

            let now = Instant::now();
            let data = do_delay(&preimage);
            let elapsed_secs = now.elapsed().as_secs();
            println!("Delay: {:?} seconds", elapsed_secs);

            let block = Block {
                height,
                elapsed_secs,
                preimage,
                data: data.clone(),
            };

            write_json(&block, &config.get_block_dir() );
            Ok(block)
        // Err(ErrorKind::Io.context(format!("submit_vdf_proof_tx_to_network {:?}", block_dir)).into())
        } else {
            return Err(ErrorKind::Io
                .context(format!("No files found in {:?}", &config.get_block_dir()))
                .into());
        }
    }

    /// Write block to file
    pub fn mine_and_submit(
        config: &OlMinerConfig,
        tx_params: TxParams,
    ) -> Result<(), Error> {
        // get the location of this miner's blocks
        let mut blocks_dir = config.workspace.home.clone();
        blocks_dir.push(&config.chain_info.block_dir);
        let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);

        // If there are NO files in path, mine the genesis proof.
        if current_block_number.is_none() {
            status_info!("Block 0","Mining Genesis Proof");
            mine_genesis(config);
            status_ok!("Proof mined:", "Genesis block_0.json created, exiting.");
            std::process::exit(0);
        } else {
            // mine continuously from the last block in the file systems
            let mut mining_height = current_block_number.unwrap() + 1; 
            loop {
                status_info!(format!("Block {}", mining_height),"Mining VDF Proof");
                
                let block = mine_once(&config)?;
                status_ok!("Proof mined:", format!("block_{}.json created.", block.height.to_string()));

                if let Some(ref _node) = config.chain_info.node {

                    let res = submit_tx(&tx_params, block.preimage, block.data, false);

                    if eval_tx_status(res) == false {
                        return Err(ErrorKind::Transaction
                            .context("Error submitting mined block")
                            .into());
                    };
                } else {
                    return Err(ErrorKind::Config
                        .context("No Node for submitting transactions")
                        .into());
                }
            
                mining_height = block.height + 1;
            }
        }
    }

    fn write_json(block: &Block, blocks_dir: &PathBuf) {
        if !&blocks_dir.exists() {
            // first run, create the directory if there is none, or if the user changed the configs.
            // note: user may have blocks but they are in a different directory than what miner.toml says.
            fs::create_dir(&blocks_dir).unwrap();
        };
        // Write the file.
        let mut latest_block_path = blocks_dir.clone();
        latest_block_path.push(format!("block_{}.json", block.height));
        //println!("{:?}", &latest_block_path);
        let mut file = fs::File::create(&latest_block_path).unwrap();
        file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
            .expect("Could not write block");
    }

    /// parse the existing blocks in the miner's path. This function receives any path. Note: the path is configured in miner.toml which abscissa Configurable parses, see commands.rs.
    pub fn parse_block_height(blocks_dir: &PathBuf) -> (Option<u64>, Option<PathBuf>) {
        let mut max_block: Option<u64> = None;
        let mut max_block_path = None;

        // iterate through all json files in the directory.
        for entry in glob(&format!("{}/block_*.json", blocks_dir.display()))
            .expect("Failed to read glob pattern")
        {
            if let Ok(entry) = entry {
                let file = fs::File::open(&entry).expect("Could not open block file");
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
    fn test_helper_clear_block_dir(blocks_dir: &PathBuf) {
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
            workspace: Workspace{
                home: PathBuf::from("."),
            },
            profile: Profile {
                auth_key: "5ffd9856978b5020be7f72339e41a401000000000000000000000000deadbeef".to_owned(),
                account: None,
                operator_private_key: None,
                ip: None,
                statement: "Protests rage across the Nation".to_owned(),
            },
            chain_info: ChainInfo {
                chain_id: "0L testnet".to_owned(),
                block_dir: "test_blocks_temp_1".to_owned(), //  path should be unique for concurrent tests.
                base_waypoint: "None".to_owned(),
                node: None,
            },
        };
        //clear from sideffects.
        test_helper_clear_block_dir( &configs_fixture.get_block_dir() );

        // mine
        mine_genesis(&configs_fixture);

        // read file
        let block_file =
            // TODO: make this work: let latest_block_path = &configs_fixture.chain_info.block_dir.to_string().push(format!("block_0.json"));
            fs::read_to_string("./test_blocks_temp_1/block_0.json").expect("Could not read latest block");

        let latest_block: Block =
            serde_json::from_str(&block_file).expect("could not deserialize latest block");

        // Test the file is read, and blockheight is 0
        assert_eq!(latest_block.height, 0, "test");

        // Test the expected proof is writtent to file correctly.
        let correct_proof = "0072c747e2b03d52a7c48497386dbac0ab8916d1a555d840f4a7d8357200c3266d6e026bfc981ab7abc1872bbc06832e6ebf0b493106f0074d56d066d73554d65c3cf209eb1eee739df5ffaacb4b88a7e487915b2255e7193e98b2db282fd9327ca21bd57af06330c4121153b132bf8b440fda42de67847b9ea80423f35c4f117cfde1560db693fbeff434900ed98c96264d4389773652d53569a1ae9e0855c4400afa4d86d094a262d7df403419952eecfc9ef4636569c25f892eb36158a6b99fbe2bb053f8deacd0b67346824a8b324412d2458f8e961998daa8efc79d8cd2a399fb40d9bb6fdb6014b464872322d96b97f6795d78ad9c749bc680fb7685792effbf344beed33a994bd20ab9da3c5ac17e70790b1d026a168751bdb1bc17e4339041e1869634a36be9e7c328a5cea9262f393714cd2470201a3db008d88f5d444cad63f874adfbfbf2a94ddd5b64be9e2a51539f844f1dadc0773ce37ad8b13b7a3e851e9faeafd1ebca9e1fdea2627116b28c2ec6d681838b803ff86c072e60bf4ab5f8a731df9463208bb33eb5faa8806bb0420d598d91a5f6ebe6917d2f90d9798d4e79b5e3bad254d17bf7412c9ae9c221139e4586b2cb73206b9a20930aa1b2d9a58b1335eff2a844344c1fe9cc70def78078f8d9a3dae999d7fde7ce8da8dff5a6430e6a9cbfa72e5162df258a2bf980428847ba273bcf935a2e60ce7bff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001";
        assert_eq!(hex::encode(&latest_block.data), correct_proof, "test");

        test_helper_clear_block_dir(&configs_fixture.get_block_dir());
    }
#[test]
#[ignore]
fn create_fixtures() {
    use libra_wallet::WalletLibrary;
    use std::path::Path;

    // if no file is found, the block height is 0
    //let blocks_dir = Path::new("./test_blocks");
    for i in 0..6 {
        let ns = i.to_string();
        let mut wallet = WalletLibrary::new();

        let (auth_key, _) = wallet.new_address().expect("Could not generate address");

        let mnemonic_string = wallet.mnemonic(); //wallet.mnemonic()

        let configs_fixture = OlMinerConfig {
            workspace: Workspace{
                home: PathBuf::from("."),
            },
            profile: Profile {
                auth_key: auth_key.to_string(),
                account: None,
                operator_private_key: None,
                ip: None,
                statement: "Protests rage across the Nation".to_owned(),
            },
            chain_info: ChainInfo {
                chain_id: "0L testnet".to_owned(),
                block_dir: "test_fixtures_miner_".to_owned() + &ns, //  path should be unique for concurrent tests.
                base_waypoint: "None".to_owned(),
                node: None,
            },
        };
        //clear from sideffects.
        let blocks_dir = Path::new(&configs_fixture.chain_info.block_dir);
        // test_helper_clear_block_dir(blocks_dir);

        // mine
        mine_genesis(&configs_fixture);

        // fs::create_dir(blocks_dir).unwrap();
        let mut latest_block_path = blocks_dir.to_path_buf();
        latest_block_path.push(format!("miner_{}.mnemonic", ns));
        let mut file = fs::File::create(&latest_block_path).expect("Could not create file");
        file.write_all(mnemonic_string.as_bytes())
            .expect("Could not write mnemonic");
    }
}


    #[test]
    fn test_mine_once() {
        // if no file is found, the block height is 0
        //let blocks_dir = Path::new("./test_blocks");

        let configs_fixture = OlMinerConfig {
            workspace: Workspace{
                home: PathBuf::from("."),
            },
            profile: Profile {
                auth_key: "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
                    .to_owned(),
                account: None,
                operator_private_key: None,
                ip: None,
                statement: "Protests rage across the Nation".to_owned(),
            },
            chain_info: ChainInfo {
                chain_id: "0L testnet".to_owned(),
                block_dir: "test_blocks_temp_2".to_owned(),
                base_waypoint: "None".to_owned(),
                node: None,
            },
        };

        // Clear at start. Clearing at end can pollute the path when tests fail.
        test_helper_clear_block_dir(&configs_fixture.get_block_dir() );

        let fixture_previous_proof = hex::decode("005f6371e754d98dd0230d051fce8462cd64257717e988ffbff95ed9b84d130b6ee1a97bff4eedc4cd28721b1f78358f8ce1a7f0b0a2e75a4740af0f328414daad2b3c205a82bbd334b7fc9ae70b8628fb7f02247b0c6416a25662202d8c63de116876b8fb575d2cffae9ea48bd511142ea5f737a9278106093e143f8c6b8d0dd13804ca601310c059ce1db3fd58eb3068dde0658a4e330cc8e5934ab2fe41e4b757e69b2edce436ceac8b0e801b66fcf453f36a4300c286039143e36dfbc100c5d0f40cd7d74a9421b3b8e547de5e82797f365c5524d35813820de538c6ef2ef980995d071a6fa26826335626f1b1b4ee256b67603b1b7df338b4607137bd433affba8a94c6f234defb09ef6d5cc697a73a5b57caf9ef8992ccf4ab35affd997c8294be37b1cfae93fe89781062cc50435fadc9be416279e02ba2eddbdbb659fbc60d8eb76f2bed5adf4a26c6a81f39eea20d65b81e91e52a38eab6229cb975bc75f46dfa65ada848234dd362aa086091fd95a0df21cb2a59d34b155a5105aef71c1a6c7ef340194f1ea3697ec59feb5ce3ea67a00149b36af5de44d2c3863e580267cffee49b9f5ba20104d65f5333c05839e5877006de9dd4c203953cc103faf82fb50a76856333fbe5b36fb6ea76123c343f2bd56192d5c300e17699659cea5acf5991643ba05fef2e399ca68d027a74c6c7c908c03adfa1b7f5c56d163ee37b00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();

        let fixture_block = Block {
            /// Block Height
            height: 0u64,
            elapsed_secs: 0u64,
            preimage: Vec::new(),
            data: fixture_previous_proof,
        };

        write_json(&fixture_block, &configs_fixture.get_block_dir() );

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

        test_helper_clear_block_dir(&configs_fixture.get_block_dir() );
    }

    #[test]
    fn test_parse_no_files() {
        // if no file is found, the block height is 0
        let blocks_dir = PathBuf::from(".");
        assert_eq!(parse_block_height(&blocks_dir).0, None);
    }

    #[test]
    fn test_parse_one_file() {
        // create a file temporarily in ./test_blocks with height 33
        let current_block_number = 33;
        let block = Block {
            height: current_block_number,
            elapsed_secs: 0u64,
            preimage: Vec::new(),
            data: Vec::new(),
        };

        // write the file temporarilty
        let blocks_dir = PathBuf::from("./test_blocks_temp_3");
        // Clear at start. Clearing at end can pollute the path when tests fail.
        test_helper_clear_block_dir(&blocks_dir);

        fs::create_dir(&blocks_dir).unwrap();
        let mut latest_block_path = blocks_dir.clone();
        latest_block_path.push(format!("block_{}.json", current_block_number));
        let mut file = fs::File::create(&latest_block_path).unwrap();
        file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
            .expect("Could not write block");

        // block height
        assert_eq!(parse_block_height(&blocks_dir).0, Some(33));

        test_helper_clear_block_dir(&blocks_dir)
    }
}
