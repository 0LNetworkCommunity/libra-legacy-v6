#![forbid(unsafe_code)]
use std::process::{Command, Stdio};
use std::{thread, time};
#[test]
pub fn test_command() {
    std::env::set_var("RUST_LOG", "debug");
    let mut echo_swarm = Command::new("cargo");
    echo_swarm.current_dir("../");
    echo_swarm.arg("run")
            .arg("-p").arg("libra-swarm")
            .arg("--").arg("-n").arg("4") 
            .arg("-l").arg("-c").arg("./saved_logs");
    //let hello_1 = echo_swarm.output().expect("failed to execute process");
    echo_swarm.stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .spawn()
            .unwrap();
    
    let mut echo_miner = Command::new("cargo");
    echo_miner.arg("run")
            .arg("submit");
    echo_miner.stdout(Stdio::inherit())
            .stderr(Stdio::inherit())
            .spawn()
            .unwrap();
    // thread::sleep(time::Duration::from_millis(60000));
    // println!("{:?}", hello_1);
    // println!("{:?}", hello_1.status.success());
}