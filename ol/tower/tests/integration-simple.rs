#![forbid(unsafe_code)]

use std::{
    fs,
    path::Path,
    process::{Command, Stdio},
    thread,
    time::{self, Duration},
};

#[test]
#[ignore]
pub fn integration() {
    // PREPARE FIXTURES
    // the transactions will always abort if the fixtures are incorrect.
    // in swarm, all validators in genesis used NodeConfig.defaul() preimage and proofs.
    // these are equivalent to fixtures/proof_0.json.test.alice
    // for the test to work:

    // the miner needs to start producing proof_1.json. If proof_1.json is not
    // successful, then block_2 cannot be either, because it depends on certain
    // on-chain state from block_1 correct submission.
    let miner_source_path = Path::new(env!("CARGO_MANIFEST_DIR"));
    let root_source_path = miner_source_path.parent().unwrap().parent().unwrap();
    let home = dirs::home_dir().unwrap();
    let swarm_configs_path = home.join("swarm_temp/");
    // clear from side effects
    fs::remove_dir_all(&swarm_configs_path).unwrap();

    let node_exec = &root_source_path.join("target/debug/diem-node");
    // TODO: Assert that proof_0.json is in blocks folder.
    std::env::set_var("RUST_LOG", "debug");
    let mut swarm_cmd = Command::new("cargo");
    swarm_cmd.current_dir(&root_source_path.as_os_str());
    swarm_cmd.arg("run")
            .arg("-p").arg("diem-swarm")
            .arg("--")
            .arg("-n").arg("1")
            .arg("--diem-node").arg(node_exec.to_str().unwrap())
            .arg("-c").arg(swarm_configs_path.to_str().unwrap());
    let cmd = swarm_cmd.stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .spawn();
    match cmd {
        // Swarm has started
        Ok(mut swarm_child) => {
            // need to wait for swarm to start-up before we have the configs
            // needed to connect to it. Check stdout.
            block_until_swarm_ready();
            println!("READY!");
            // wait a bit more, because the previous command only checks for
            // config fils creation.
            let test_timeout = Duration::from_secs(30);
            thread::sleep(test_timeout);

            // start the miner swarm test helper.
            let mut init_cmd = Command::new("cargo");
            init_cmd
                .arg("run")
                .arg("-p")
                .arg("ol")
                .arg("--")
                .arg("--swarm-path")
                .arg(swarm_configs_path.to_str().unwrap())
                .arg("--swarm-persona")
                .arg("alice")
                .arg("init")
                .arg("--source-path")
                .arg(root_source_path.to_str().unwrap());
            let mut init_child = init_cmd
                .stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .spawn()
                .unwrap();
            init_child.wait().unwrap();

            // start the miner swarm test helper.
            let mut miner_cmd = Command::new("cargo");
            miner_cmd
                .arg("run")
                .arg("-p")
                .arg("miner")
                .arg("--")
                .arg("--swarm-path")
                .arg(swarm_configs_path.to_str().unwrap())
                .arg("--swarm-persona")
                .arg("alice")
                .arg("start");
            let mut miner_child = miner_cmd
                .stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .spawn()
                .unwrap();

            // TODO: need to parse output of the stdio

            // set a timeout
            let test_timeout = Duration::from_secs(120);
            thread::sleep(test_timeout);
            init_child.kill().unwrap();
            swarm_child.kill().unwrap();
            miner_child.kill().unwrap();

            // TODO: get output and evaluate with assert
            // assert_eq!()
        }
        Err(err) => println!("Swarm child process did not start: {}", err),
    }
}

fn block_until_swarm_ready() -> bool {
    let home = dirs::home_dir().unwrap();
    let swarm_configs_path = home.join("swarm_temp/");
    let mut timeout = 100;
    let one_second = time::Duration::from_secs(1);

    loop {
        if timeout == 0 {
            return false;
        }
        if swarm_configs_path.exists() {
            return true;
        }

        thread::sleep(one_second);
        timeout -= 1;
    }
}
