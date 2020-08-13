#![forbid(unsafe_code)]
use std::process::{Command, Stdio};
use wait_timeout::ChildExt;
use std::time::Duration;
#[test]
pub fn test_command() {
    std::env::set_var("RUST_LOG", "debug");
    let mut echo_swarm = Command::new("cargo");
    echo_swarm.current_dir("../");
    echo_swarm.arg("run")
            .arg("-p").arg("libra-swarm")
            .arg("--").arg("-n").arg("4") 
            .arg("-l").arg("-c").arg("./saved_logs");
    let cmd = echo_swarm.stdout(Stdio::inherit())
                .stderr(Stdio::inherit())
                .spawn();

    match cmd {
        Ok(mut child) => {
            let timeout = Duration::from_secs(540);
    
            match child.wait_timeout(timeout) {
                Ok(Some(status)) => println!("Exited with status {}", status),
                Ok(None) => {
                        println!("timeout, process is still alive");

                        let mut echo_miner = Command::new("cargo");
                        echo_miner.arg("run")
                                .arg("submit");
                        echo_miner.stdout(Stdio::inherit())
                                .stderr(Stdio::inherit())
                                .spawn().unwrap();
                        ()           
                } ,
                Err(e) => println!("Error waiting: {}", e),
            }
        }
        Err(err) => println!("Process did not even start: {}", err)
    }
}