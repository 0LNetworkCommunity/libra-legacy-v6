#![forbid(unsafe_code)]
use std::process::{Command, Stdio};
use wait_timeout::ChildExt;
use std::{path::PathBuf, time::{self, Duration}, fs, thread};
#[test]
pub fn integration() {

    // PREPARE FIXTURES
    // the transactions will always abort if the fixtures are incorrect.
    // in swarm, all validators in genesis used NodeConfig.defaul() preimage and proofs.
    // these are equivalent to fixtures/block_0.json.test.alice 
    // for the test to work:

    // the miner needs to start producing block_1.json. If block_1.json is not successful, then block_2 cannot be either, because it depends on certain on-chain state from block_1 correct submission.
    
    // remove all files in miner/blocks/
    let blocks_dir = PathBuf::from("./blocks/");

    if blocks_dir.exists() {
        fs::remove_dir_all(&blocks_dir).unwrap();
    } else {
        fs::create_dir(&blocks_dir).unwrap();
    }
    // copy fixtures/block_0.json.test.alice -> blocks/block_0.json
    fs::copy("~/libra/fixtures/block_0.json.test.alice", "~/libra/miner/blocks/block_0.json");
    
    // TODO: Assert that block_0.json is in blocks folder.
    std::env::set_var("RUST_LOG", "debug");
    let mut echo_swarm = Command::new("cargo");
    echo_swarm.current_dir("../");
    echo_swarm.arg("run")
            .arg("-p").arg("libra-swarm")
            .arg("--").arg("-n").arg("1") 
            .arg("-l").arg("-c").arg("./saved_logs");
    let cmd = echo_swarm.stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .spawn();

    match cmd {
        // Swarm has started
        Ok(mut swarm_child) => {
            // need to wait for swarm to start-up before we have the configs needed to connect to it.
            let wait_for_swarm = Duration::from_secs(15);
            thread::sleep(wait_for_swarm);

            let mut echo_miner = Command::new("cargo");
            echo_miner.arg("run")
                    .arg("swarm");
            echo_miner.stdout(Stdio::inherit())
                    .stderr(Stdio::inherit())
                    .spawn().unwrap();
            // what to do at timeout.
            // TODO: get output and evaluate with assert
            // assert_eq!()
            
            let test_timeout = Duration::from_secs(600);

            match swarm_child.wait_timeout(test_timeout) {
                Ok(Some(status)) => println!("Exited with status {}", status),
                Ok(None) => {
                    println!("Test will exit now, time taken: {:?}", test_timeout);



                    swarm_child.kill().unwrap();
                    // echo_swarm.kill().unwrap();
                },
                Err(e) => println!("Error waiting: {}", e),
            }
        }
        Err(err) => println!("Process did not even start: {}", err)
    }
}