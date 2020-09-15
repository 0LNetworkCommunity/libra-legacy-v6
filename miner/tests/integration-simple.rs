
#![forbid(unsafe_code)]

use std::{
    path::{PathBuf, Path},
    time::{self, Duration},
    fs,
    thread,
    process::{Command, Stdio},
};


#[test]
#[ignore]
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
    }
    fs::create_dir(&blocks_dir).unwrap();

    // copy fixtures/block_0.json.test.alice -> blocks/block_0.json
    let _ = fs::copy("../fixtures/block_0.json.test.alice", "blocks/block_0.json");

    // clean config dir
    let config_dir = PathBuf::from("../saved_logs");
    if config_dir.exists() {
        fs::remove_dir_all(&config_dir).unwrap();
    }

    // TODO: Assert that block_0.json is in blocks folder.
    std::env::set_var("RUST_LOG", "debug");
    let mut swarm_cmd = Command::new("cargo");
    swarm_cmd.current_dir("../");
    swarm_cmd.arg("run")
            .arg("-p").arg("libra-swarm")
            .arg("--").arg("-n").arg("1") 
            .arg("-l").arg("-c").arg("saved_logs");
    let cmd = swarm_cmd.stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .spawn();
    match cmd {
        // Swarm has started
        Ok(mut swarm_child) => {
            // need to wait for swarm to start-up before we have the configs needed to connect to it. Check stdout.
            block_until_swarm_ready();
            // wait a bit more, because the previous command only checks for config fils creation.

            let test_timeout = Duration::from_secs(30);
            thread::sleep(test_timeout);
            println!("READY!");

            // start the miner swarm test helper.
            let mut miner_cmd = Command::new("cargo");
            miner_cmd.arg("run")
                    .arg("swarm");
            let mut miner_child = miner_cmd.stdout(Stdio::inherit())
                    .stderr(Stdio::inherit())
                    .spawn()
                    .unwrap();

            // set a timeout
            let test_timeout = Duration::from_secs(120);
            thread::sleep(test_timeout);
            swarm_child.kill().unwrap();
            miner_child.kill().unwrap();

            // TODO: get output and evaluate with assert
            // assert_eq!()

        }
        Err(err) => println!("Process did not even start: {}", err)
    }
}

fn block_until_swarm_ready () -> bool {
    let _swarm_configs_path = Path::new("../saved_logs/");
    let mut timeout = 100;
    let one_second = time::Duration::from_secs(1);

    loop {
        if timeout == 0 { 
            return false
        }
        if Path::new("../saved_logs/").exists() {
            return true
        }

        thread::sleep(one_second);
        timeout -= 1;
    }
}


// #[test]
// pub fn test_echo () {
//    echo();
// }


// fn echo() -> Result<bool, Error> {
//     let child = Command::new("git").arg("log").arg("--oneline")
//     .stdout(Stdio::piped())
//     .spawn()?;

//     // if !output.status.success() {
//     //     bail!("Command executed with failing error code");
//     // }

//     let pattern = Regex::new(r"(?x)
//                                (competition) # commit hash
//                                (.*)           # The commit message")?;

    
//     let output = child.wait_with_output().unwrap();

//     let out = BufReader::new(&*output.stdout);

//     let exists = out.lines()
//     .any(|line| pattern.captures(&line.as_ref().unwrap()).is_some());
//     // .for_each(|line| {
//     //     println!("out: {:?}", line);
//     // });
//     println!("exists: {:?}", exists);

//     Ok(true)

// }


// #[test]
// pub fn dir () {
//     assert_eq!( block_until_swarm_ready(), true);
// }

