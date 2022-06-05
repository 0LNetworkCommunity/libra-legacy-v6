//! Proof block datastructure

use crate::{backlog, delay::*, preimage::genesis_preimage};
use anyhow::{bail, Error};
use diem_crypto::hash::HashValue;
use diem_global_constants::{delay_difficulty, VDF_SECURITY_PARAM};
use glob::glob;
use ol_types::block::VDFProof;
use ol_types::config::AppCfg;
use std::{
    fs,
    io::{BufReader, Write},
    path::PathBuf,
    time::Instant,
};
use txs::tx_params::TxParams;

/// name of the proof files
pub const FILENAME: &str = "proof";

// writes a JSON file with the first vdf proof
fn mine_genesis(config: &AppCfg, difficulty: u64, security: u16) -> VDFProof {
    println!("Mining Genesis Proof");
    let preimage = genesis_preimage(&config);
    let now = Instant::now();

    let proof = do_delay(&preimage, difficulty, security).unwrap(); // Todo: make mine_genesis return a result.
    let elapsed_secs = now.elapsed().as_secs();
    println!("Delay: {:?} seconds", elapsed_secs);
    let block = VDFProof {
        height: 0u64,
        elapsed_secs,
        preimage,
        proof,
        difficulty: Some(difficulty),
        security: Some(security),
    };

    block
}

/// Mines genesis and writes the file
pub fn write_genesis(config: &AppCfg) -> Result<VDFProof, Error> {
    let difficulty = delay_difficulty();
    let security = VDF_SECURITY_PARAM;
    let block = mine_genesis(config, difficulty, security);
    //TODO: check for overwriting file...
    write_json(&block, &config.get_block_dir())?;
    let genesis_proof_filename = &format!("{}_0.json", FILENAME);
    println!(
        "proof zero mined, file saved to: {:?}",
        &config.get_block_dir().join(genesis_proof_filename)
    );
    Ok(block)
}
/// Mine one block
pub fn mine_once(config: &AppCfg) -> Result<VDFProof, Error> {
    // If there are files in path, continue mining.
    // let latest_block = ?;
    let (preimage, height) = match get_latest_proof(config) {
      Ok(latest_block) => (HashValue::sha3_256_of(&latest_block.proof).to_vec(), latest_block.height + 1 ),
      // Otherwise this is the first time the app is run, and it needs a genesis preimage, which comes from configs.
      Err(_) => return write_genesis(config)
    };

    // TODO: cleanup this duplication with mine_genesis_once?
    let difficulty = delay_difficulty();
    let security = VDF_SECURITY_PARAM;

    let now = Instant::now();
    let data = do_delay(&preimage, difficulty, security)?;
    let elapsed_secs = now.elapsed().as_secs();
    println!("Delay: {:?} seconds", elapsed_secs);

    let block = VDFProof {
        height,
        elapsed_secs,
        preimage,
        proof: data.clone(),
        difficulty: Some(difficulty),
        security: Some(security),
    };

    write_json(&block, &config.get_block_dir())?;
    Ok(block)
}

/// Write block to file
pub fn mine_and_submit(
    config: &AppCfg,
    tx_params: TxParams
) -> Result<(), Error> {
    // get the location of this miner's blocks
    let mut blocks_dir = config.workspace.node_home.clone();
    blocks_dir.push(&config.workspace.block_dir);
    let (current_block_number, _current_block_path) = parse_block_height(&blocks_dir);

    // If there are NO files in path, mine the genesis proof.
    if current_block_number.is_none() {
        bail!("ERROR: no valid proof found.");
    } else {
        // the max block that has been succesfully submitted to client
        let mut mining_height = current_block_number.unwrap() + 1;
        // in the beginning, mining height is +1 of client block number

        // mine continuously from the last block in the file systems
        loop {
            println!("Mining VDF Proof # {}", mining_height);

            let block = mine_once(&config)?;
            println!(
                "Proof mined: proof_{}.json created.",
                block.height.to_string()
            );

            // submits backlog to client
            match backlog::process_backlog(&config, &tx_params) {
                Ok(()) => println!("Success: Proof committed to chain"),
                Err(e) => {
                    // don't stop on tx errors
                    println!("ERROR: Failed processing backlog, message: {:?}", e);
                }
            }

            mining_height = block.height + 1;
        }
    }
}

fn write_json(block: &VDFProof, blocks_dir: &PathBuf) -> Result<(), std::io::Error> {
    if !&blocks_dir.exists() {
        // first run, create the directory if there is none, or if the user changed the configs.
        // note: user may have blocks but they are in a different directory than what miner.toml says.
        fs::create_dir(&blocks_dir)?;
    };
    // Write the file.
    let mut latest_block_path = blocks_dir.clone();
    latest_block_path.push(format!("{}_{}.json", FILENAME, block.height));
    let mut file = fs::File::create(&latest_block_path)?;
    file.write_all(serde_json::to_string(&block)?.as_bytes())
}

/// parse the existing blocks in the miner's path. This function receives any path. Note: the path is configured in miner.toml which abscissa Configurable parses, see commands.rs.
pub fn parse_block_height(blocks_dir: &PathBuf) -> (Option<u64>, Option<PathBuf>) {
    let mut max_block: Option<u64> = None;
    let mut max_block_path = None;

    // iterate through all json files in the directory.
    for entry in glob(&format!("{}/{}_*.json", blocks_dir.display(), FILENAME))
        .expect("Failed to read glob pattern")
    {
        if let Ok(entry) = entry {
            let file = fs::File::open(&entry).expect("Could not open block file");
            let reader = BufReader::new(file);
            let block: VDFProof = serde_json::from_reader(reader).expect(&format!("could not parse epoch proof {:?}", &entry));
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

/// Parse a proof_x.json file and return a VDFProof
pub fn parse_block_file(path: &PathBuf) -> Result<VDFProof, Error> {
    let block_file = fs::read_to_string(path).expect("Could not read latest block file in path");

    match serde_json::from_str(&block_file) {
        Ok(v) => Ok(v),
        Err(e) => bail!(e),
    }
}

/// find the most recent proof on disk
pub fn get_latest_proof(config: &AppCfg) -> Result<VDFProof, Error> {
    let (_current_block_number, current_block_path) = parse_block_height(&config.get_block_dir());

    match current_block_path {
        // current_block_path is Option type, check if destructures to Some.
        Some(p) => parse_block_file(&p),
        None => bail!(format!(
            "ERROR: cannot find a block in directory, path: {:?}",
            &config.get_block_dir()
        )),
    }
}

/* ////////////// */
/* / Unit tests / */
/* ////////////// */

// Tests generate side-effects. For now run sequentially with `cargo test -- --test-threads 1`
#[allow(dead_code)]
fn test_helper_clear_block_dir(blocks_dir: &PathBuf) {
    // delete the temporary test file and directory.
    // remove_dir_all is scary: be careful with this.
    if blocks_dir.exists() {
        fs::remove_dir_all(blocks_dir).unwrap();
    }
}
#[test]
#[ignore]
//Not really a test, just a way to generate fixtures.
fn create_fixtures() {
    use diem_wallet::WalletLibrary;

    // if no file is found, the block height is 0
    //let blocks_dir = Path::new("./test_blocks");
    for i in 0..6 {
        let ns = i.to_string();
        let mut wallet = WalletLibrary::new();

        let (_auth_key, _) = wallet.new_address().expect("Could not generate address");

        let mnemonic_string = wallet.mnemonic(); //wallet.mnemonic()
        let save_to = format!("./test_fixtures_{}/", ns);
        fs::create_dir_all(save_to.clone()).unwrap();
        let mut configs_fixture = test_make_configs_fixture();
        configs_fixture.workspace.block_dir = save_to.clone();

        // mine to save_to path
        write_genesis(&configs_fixture).unwrap();

        // also create mnemonic
        let mut mnemonic_path = PathBuf::from(save_to.clone());
        mnemonic_path.push("owner.mnem");
        dbg!(&mnemonic_path);
        let mut file = fs::File::create(&mnemonic_path).expect("Could not create file");
        file.write_all(mnemonic_string.as_bytes())
            .expect("Could not write mnemonic");

        // create miner.toml
        //rename the path for actual fixtures
        configs_fixture.workspace.block_dir = "vdf_proofs".to_string();
        let toml = toml::to_string(&configs_fixture).unwrap();
        let mut toml_path = PathBuf::from(save_to);
        toml_path.push("miner.toml");
        let file = fs::File::create(&toml_path);
        file.unwrap()
            .write(&toml.as_bytes())
            .expect("Could not write toml");
    }
}

#[test]
fn test_mine_once() {
    use hex::decode;
    // if no file is found, the block height is 0
    let mut configs_fixture = test_make_configs_fixture();
    configs_fixture.workspace.block_dir = "test_blocks_temp_2".to_owned();

    // Clear at start. Clearing at end can pollute the path when tests fail.
    test_helper_clear_block_dir(&configs_fixture.get_block_dir());

    let fixture_previous_proof = decode("0016f43606b957ab9d93046cdffa73a1e6be4f21f3848eb7b55b81756f7d31919affef388c0d92ca7d68232de4fea46884186c23ef1d6c86f63f5c586000048bce05").unwrap();

    let fixture_block = VDFProof {
        height: 0u64, // Tower height
        elapsed_secs: 0u64,
        preimage: Vec::new(),
        proof: fixture_previous_proof,
        difficulty: Some(100),
        security: Some(2048),
    };

    write_json(&fixture_block, &configs_fixture.get_block_dir()).unwrap();
    mine_once(&configs_fixture).unwrap();
    // confirm this file was written to disk.
    let block_file = fs::read_to_string("./test_blocks_temp_2/proof_1.json")
        .expect("Could not read latest block");
    let latest_block: VDFProof =
        serde_json::from_str(&block_file).expect("could not deserialize latest block");
    // Test the file is read, and blockheight is 0
    assert_eq!(latest_block.height, 1, "Not the droid you are looking for.");

    // Test the expected proof is writtent to file correctly.
    let correct_proof = "006036397bd5c35644e2b20f2334a5343911de7cf29588654c322c0fc063c1a2c50000bc9923bdb96a97beaf67f3530ad00f735b7a795ea651f6a88cfd4deeb5aa29";
    assert_eq!(
        hex::encode(&latest_block.proof),
        correct_proof,
        "Not the proof of the new block created"
    );

    test_helper_clear_block_dir(&configs_fixture.get_block_dir());
}

#[test]
fn test_mine_genesis() {
    // if no file is found, the block height is 0
    //let blocks_dir = Path::new("./test_blocks");
    let configs_fixture = test_make_configs_fixture();

    //clear from sideffects.
    test_helper_clear_block_dir(&configs_fixture.get_block_dir());

    // mine
    write_genesis(&configs_fixture).unwrap();
    // read file
    let block_file =
        // TODO: make this work: let latest_block_path = &configs_fixture.chain_info.block_dir.to_string().push(format!("proof_0.json"));
        fs::read_to_string("./test_blocks_temp_1/proof_0.json").expect("Could not read latest block");

    let latest_block: VDFProof =
        serde_json::from_str(&block_file).expect("could not deserialize latest block");

    // Test the file is read, and blockheight is 0
    assert_eq!(latest_block.height, 0, "test");

    // Test the expected proof is writtent to file correctly.
    let correct_proof = "00292f460bffb29e5d3a7fe5fe7a560104b83a48a236a819812b33e5a3ef2ec266fff30541a78101b4e266358c965ac65830f955842c6dee22b103b50f4709a51655";
    assert_eq!(hex::encode(&latest_block.proof), correct_proof, "test");

    test_helper_clear_block_dir(&configs_fixture.get_block_dir());
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
    let block = VDFProof {
        height: current_block_number,
        elapsed_secs: 0u64,
        preimage: Vec::new(),
        proof: Vec::new(),
        difficulty: Some(100),
        security: Some(2048),
    };

    // write the file temporarilty
    let blocks_dir = PathBuf::from("./test_blocks_temp_3");
    // Clear at start. Clearing at end can pollute the path when tests fail.
    test_helper_clear_block_dir(&blocks_dir);

    fs::create_dir(&blocks_dir).unwrap();
    let mut latest_block_path = blocks_dir.clone();
    latest_block_path.push(format!("proof_{}.json", current_block_number));
    let mut file = fs::File::create(&latest_block_path).unwrap();
    file.write_all(serde_json::to_string(&block).unwrap().as_bytes())
        .expect("Could not write block");

    // block height
    assert_eq!(parse_block_height(&blocks_dir).0, Some(33));

    test_helper_clear_block_dir(&blocks_dir)
}

/// make fixtures for file
pub fn test_make_configs_fixture() -> AppCfg {
    let mut cfg = AppCfg::default();
    cfg.workspace.node_home = PathBuf::from(".");
    cfg.workspace.block_dir = "test_blocks_temp_1".to_owned();
    cfg.chain_info.chain_id = "0L testnet".to_owned();
    cfg.profile.auth_key = "3e4629ba1e63114b59a161e89ad4a083b3a31b5fd59e39757c493e96398e4df2"
        .parse()
        .unwrap();
    cfg
}
