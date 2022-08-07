//! `management` functions

use crate::{
    node::node::{self, Node},
    prelude::app_config,
};
use anyhow::Error;
use ol_types::config::IS_PROD;
use serde::{Deserialize, Serialize};
use std::{
    collections::HashSet,
    fs::{self, File},
    process::{exit, Command, Stdio},
};
const BINARY_NODE: &str = "diem-node";
const BINARY_MINER: &str = "tower";

#[derive(Debug, Clone, PartialEq, Deserialize, Serialize)]
/// What kind of node are we starting
pub enum NodeMode {
    /// Validator
    Validator,
    /// Fullnode
    Fullnode,
}

/// Process name and its set of PIDs ever spawned
#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct HostProcess {
    name: String,
    pids: HashSet<u32>,
}

/// create log files
pub fn create_log_file(file_name: &str) -> File {
    let conf = app_config();
    let logs_dir = conf.workspace.node_home.join("logs/");
    fs::create_dir_all(&logs_dir).expect("could not create logs dir");
    let logs_file = logs_dir.join([file_name, ".log"].join(""));
    //println!("Logging in file: {:?}", logs_file);

    File::create(logs_file).expect("could not create log file")
}

/// Spawn process with some options
fn spawn_process(
    binary: &str,
    args: &[&str],
    log_file: &str,
    _expect_msg: &str,
) -> std::io::Result<std::process::Child> {
    // Create log file, and pipe stdout/err
    let outputs = create_log_file(log_file);
    let errors = outputs.try_clone().unwrap();

    Command::new(binary)
        .args(args)
        .stdout(Stdio::from(outputs))
        .stderr(Stdio::from(errors))
        .spawn()
}

impl Node {
    /// Start Node, as fullnode
    pub fn start_node(&mut self, verbose: bool) -> Result<(), Error> {
        use BINARY_NODE as NODE;
        // if is running do nothing
        // TODO: Get another check of node running
        if node::Node::node_running() {
            if verbose {
                println!("{} is already running. Exiting.", NODE);
            }
            return Ok(());
        }

        // Start as validator or fullnode
        let conf = app_config();
        let node_home = conf.workspace.node_home.to_str().unwrap();
        let config_file_name = format!("{}validator.node.yaml", node_home);

        let child = if *IS_PROD {
            let args = vec!["--config", &config_file_name];
            if verbose {
                println!("Starting '{}' with args: {:?}", NODE, args.join(" "));
            }
            spawn_process(
                NODE,
                args.as_slice(),
                "node",
                "failed to run 'diem-node', is it installed?",
            )
        } else {
            let project_root = self.app_conf.workspace.source_path.clone().unwrap();
            let debug_bin = project_root.join(format!("target/debug/{}", NODE));
            let bin_str = debug_bin.to_str().unwrap();
            let args = vec!["--config", &config_file_name];
            if verbose {
                println!("Starting 'diem-node' with args: {:?}", args.join(" "));
            }
            spawn_process(
                bin_str,
                args.as_slice(),
                "node",
                &format!("failed to run {:?}", bin_str),
            )
        };

        if let Ok(ch) = child {
            let pid = &ch.id();
            self.save_pid(NODE, *pid);
            if verbose {
                println!("Started with PID {} in the background", pid);
            }
        }
        Ok(())
    }

    /// Start Miner
    pub fn start_miner(&mut self, _verbose: bool) {
        // Stop any processes we may have started and detached from.
        // if is running do nothing
        use BINARY_MINER as MINER;
        if node::Node::miner_running() {
            println!("{} is already running. Exiting.", MINER);
            return;
        }

        let child = if *IS_PROD {
            // start as operator, so that mnemonic is not needed.
            let args = vec!["-o", "start"];
            // if use_backup { args.push("--backup-url"); };
            if _verbose {
                println!("Starting '{}' with args: {:?}", MINER, args.join(" "));
            }
            spawn_process(
                MINER,
                args.as_slice(),
                MINER,
                "failed to run 'miner', is it installed?",
            )
        } else {
            let project_root = self.app_conf.workspace.source_path.clone().unwrap();
            let debug_bin = project_root.join(format!("target/debug/{}", MINER));
            let bin_str = debug_bin.to_str().unwrap();
            // start as operator, so that mnemonic is not needed.
            let args = vec!["-o", "start"];
            if _verbose {
                println!("Starting 'miner' with args: {:?}", args.join(" "));
            }
            spawn_process(
                bin_str,
                args.as_slice(),
                MINER,
                &format!("failed to run {}", bin_str),
            )
        };

        if let Ok(ch) = child {
            let pid = &ch.id();
            self.save_pid(MINER, *pid);
            if _verbose {
                println!("Started with PID {} in the background", pid);
            }
        }
    }

    /// Start Monitor
    pub fn start_web(&mut self, _verbose: bool) {
        // if verbose { drop(print_gag); }
        // Stop any processes we may have started and detached from.
        // if is running do nothing
        if node::Node::is_web_monitor_serving() {
            if _verbose {
                println!("web monitor is already running. Exiting.");
            }
            return;
        }

        let child = if *IS_PROD {
            if _verbose {
                println!("Starting `ol serve`");
            }
            spawn_process(
                "ol",
                &["serve"],
                "monitor",
                "failed to run 'ol', is it installed?",
            )
        } else {
            let project_root = match self.app_conf.workspace.source_path.clone() {
                Some(p) => p,
                None => {
                    println!("ERROR: can't start web-monitor in dev mode. It doesn't seem like you have workspace.source_path set in 0L.toml. Exiting.");
                    exit(1);
                }
            };

            let debug_bin = project_root.join("target/debug/ol");
            let bin_str = debug_bin.to_str().unwrap();

            let args = vec!["serve"];
            if _verbose {
                println!("Starting '{}' with args: {:?}", bin_str, args.join(" "));
            }
            spawn_process(
                bin_str,
                args.as_slice(),
                "monitor",
                &format!("failed to run: {}", bin_str),
            )
        };

        if let Ok(ch) = child {
            let pid = &ch.id();
            self.save_pid("monitor", *pid);
            if _verbose {
                println!("Started with PID {} in the background", pid);
            }
        }
    }

    /// Start pilot, for explorer
    pub fn start_pilot(&mut self, verbose: bool) {
        if Node::pilot_running() {
            return;
        }

        let mut args = vec!["pilot"];
        if verbose {
            args.push("-s");
        }
        let child = if *IS_PROD {
            println!("Starting `ol pilot`");
            spawn_process(
                "ol",
                args.as_slice(),
                "pilot",
                "failed to run 'ol', is it installed?",
            )
        } else {
            let project_root = self.app_conf.workspace.source_path.clone().unwrap();
            let debug_bin = project_root.join("target/debug/ol");
            let bin_str = debug_bin.to_str().unwrap();
            println!("Starting '{}' with args: {:?}", bin_str, args.join(" "));
            spawn_process(
                bin_str,
                args.as_slice(),
                "pilot",
                &format!("failed to run: {}", bin_str),
            )
        };

        let pid = &child.unwrap().id();
        self.save_pid("pilot", *pid);
        println!("Started with PID {} in the background", pid);
    }

    /// Save PID
    pub fn save_pid(&mut self, proc_name: &str, pid: u32) {
        // Handle empty case
        match proc_name {
            "node" => {
                self.vitals.node_proc =
                    create_or_insert(&mut self.vitals.node_proc, proc_name, pid);
            }
            "miner" => {
                self.vitals.miner_proc =
                    create_or_insert(&mut self.vitals.miner_proc, proc_name, pid);
            }

            "monitor" => {
                self.vitals.monitor_proc =
                    create_or_insert(&mut self.vitals.miner_proc, proc_name, pid);
            }
            _ => return,
        };

        fn create_or_insert(
            hp: &mut Option<HostProcess>,
            proc_name: &str,
            pid: u32,
        ) -> Option<HostProcess> {
            match hp {
                Some(p) => {
                    p.pids.insert(pid);
                    Some(p.to_owned())
                }
                None => {
                    let p = HostProcess {
                        name: proc_name.to_owned(),
                        pids: vec![pid].into_iter().collect(),
                    };
                    Some(p.to_owned())
                }
            }
        }
    }

    fn get_process(&self, proc_name: &str) -> Option<HostProcess> {
        match proc_name {
            "node" => self.vitals.node_proc.clone(),
            "tower" => self.vitals.miner_proc.clone(),
            "monitor" => self.vitals.monitor_proc.clone(),
            _ => None,
        }
    }

    /// Kill all the processes that are running
    pub fn kill_zombies(&self, name: &str) {
        println!("Killing zombie '{}' processes...", name);
        println!("Will NOT disable any systemd services, you must disable those manually");
        use nix::sys::signal::{self, Signal};

        if let Some(hp) = self.get_process(name) {
            for pid in hp.pids.iter() {
                let _res = signal::kill(nix::unistd::Pid::from_raw(*pid as i32), Signal::SIGTERM);
            }
        }
    }
    /// Stop node, as validator
    pub fn stop_node(&self) {
        self.kill_all(BINARY_NODE);
    }

    /// Kill processes every way we know how
    pub fn kill_all(&self, process: &str) {
        self.kill_zombies(process);

        let mut child = Command::new("killall")
            .arg(process)
            .spawn()
            .expect(&format!("failed to run killall {}", process));
        child.wait().expect("killall did not exit");
    }
    /// Stop Miner
    pub fn stop_miner(&self) {
        self.kill_all(BINARY_MINER);
    }
}
