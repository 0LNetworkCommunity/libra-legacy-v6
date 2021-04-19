//! `management` functions

use crate::{
  cache::DB_CACHE_READ,
  entrypoint,
  node::node::{self, Node},
  prelude::app_config,
};
use anyhow::Error;
use once_cell::sync::Lazy;

use serde::{Deserialize, Serialize};
use std::{
  collections::HashSet,
  env,
  fs::{self, File},
  process::{Command, Stdio},
};

const BINARY_NODE: &str = "libra-node";
const BINARY_MINER: &str = "miner";

#[derive(Debug)]
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

/// Check if we are in prod mode
pub static IS_PROD: Lazy<bool> = Lazy::new(|| {
  match env::var("NODE_ENV") {
    Ok(val) => {
      match val.as_str() {
        "prod" => true,
        // if anything else is set by user is false
        _ => false,
      }
    }
    // default to prod if nothig is set
    _ => true,
  }
});

/// Kill all the processes that are running
pub fn kill_zombies(name: &str) {
  if DB_CACHE_READ.get(name.as_bytes()).unwrap().is_none() {
    return;
  }

  let pids_loaded = DB_CACHE_READ.get(name.as_bytes()).unwrap().unwrap();
  let process: HostProcess = serde_json::de::from_slice(&pids_loaded).unwrap();

  println!("Killing zombie '{}' processes...", name);
  println!("Will node disable any systemd services, you must disable those manually");
  use nix::sys::signal::{self, Signal};
  for pid in process.pids.iter() {
    let _res = signal::kill(nix::unistd::Pid::from_raw(*pid as i32), Signal::SIGTERM);
  }
}

/// create log files
pub fn create_log_file(file_name: &str) -> File {
  let conf = app_config();
  let logs_dir = conf.workspace.node_home.join("logs/");
  fs::create_dir_all(&logs_dir).expect("could not create logs dir");
  let logs_file = logs_dir.join([file_name, ".log"].join(""));
  println!("Logging in file: {:?}", logs_file);

  File::create(logs_file).expect("could not create log file")
}

/// Stop node, as validator
pub fn stop_node() {
  kill_all(BINARY_NODE);
}

fn kill_all(process: &str) {
  kill_zombies(process);

  let mut child = Command::new("killall")
    .arg(process)
    .spawn()
    .expect(&format!("failed to run killall {}", process));
  child.wait().expect("killall did not exit");
}

/// Spawn process with some options
fn spawn_process(
  binary: &str,
  args: &[&str],
  log_file: &str,
  expect_msg: &str,
) -> std::process::Child {
  // Create log file, and pipe stdout/err
  let outputs = create_log_file(log_file);
  let errors = outputs.try_clone().unwrap();

  Command::new(binary)
    .args(args)
    .stdout(Stdio::from(outputs))
    .stderr(Stdio::from(errors))
    .spawn()
    .expect(expect_msg)
}

/// Stop Miner
pub fn stop_miner() {
  kill_all(BINARY_MINER);
}

/// start validator wizard
pub fn run_validator_wizard() -> bool {
  println!("Running validator wizard");
  let entry_arg = entrypoint::get_args();

  let mut child = if *IS_PROD {
    Command::new("miner")
      .arg("val-wizard")
      .spawn()
      .expect(&format!("failed to find 'miner', is it installed?"))
  } else if let Some(path) = entry_arg.swarm_path {
    // we are testing with swarm
    let swarm_arg = path.to_str().unwrap();
    let swarm_persona = entry_arg.swarm_persona.unwrap();

    Command::new("cargo")
      .args(&["r", "-p", "miner", "--"])
      .arg("--swarm-path")
      .arg(swarm_arg)
      .arg("--swarm-persona")
      .arg(swarm_persona)
      .arg("val-wizard")
      .spawn()
      .expect(&format!("failed to run cargo r -p miner"))
  } else {
    // we are testing on devnet
    Command::new("cargo")
      .args(&["r", "-p", "miner", "--"])
      .arg("val-wizard")
      .spawn()
      .expect(&format!("failed to run cargo r -p miner"))
  };

  let exit_code = child.wait().expect("failed to wait on miner");
  assert!(exit_code.success());

  true
}

impl Node {
  /// Start Node, as fullnode
  pub fn start_node(&mut self, config_type: NodeMode) -> Result<(), Error> {
    use BINARY_NODE as NODE;
    // if is running do nothing
    // TODO: Get a nother check of node running
    if node::Node::node_running() {
      println!("{} is already running. Exiting.", NODE);
      return Ok(());
    }

    // Start as validator or fullnode
    let conf = app_config();
    let node_home = conf.workspace.node_home.to_str().unwrap();
    let config_file_name = match config_type {
      NodeMode::Validator => format!("{}validator.node.yaml", node_home),
      NodeMode::Fullnode => format!("{}fullnode.node.yaml", node_home),
    };

    let child = if *IS_PROD {
      let args = vec!["--config", &config_file_name];
      println!("Starting '{}' with args: {:?}", NODE, args.join(" "));
      spawn_process(
        NODE,
        args.as_slice(),
        "node",
        "failed to run 'libra-node', is it installed?",
      )
    } else {
      let args = vec!["r", "-p", NODE, "--", "--config", &config_file_name];
      println!("Starting 'cargo' with args: {:?}", args.join(" "));
      spawn_process(
        "cargo",
        args.as_slice(),
        "node",
        "failed to run cargo r -p libra-node",
      )
    };

    let pid = &child.id();
    self.save_pid(NODE, *pid);
    println!("Started new with PID: {}", pid);
    Ok(())
  }

  /// Start Miner
  pub fn start_miner(&mut self) {
    // Stop any processes we may have started and detached from.
    // if is running do nothing
    use BINARY_MINER as MINER;
    if node::Node::miner_running() {
      println!("{} is already running. Exiting.", MINER);
      return;
    }

    // if node is NOT synced, then should use a backup/upstream node
    // let url = choose_rpc_node().unwrap();
    // let use_backup = node_health::NodeHealth::node_is_synced(config).0;

    let child = if *IS_PROD {
      let args = vec!["start"];
      // if use_backup { args.push("--backup-url"); };
      println!("Starting '{}' with args: {:?}", MINER, args.join(" "));
      spawn_process(
        MINER,
        args.as_slice(),
        MINER,
        "failed to run 'miner', is it installed?",
      )
    } else {
      let args = vec!["r", "-p", MINER, "--", "start"];
      // if use_backup { args.push("--backup-url"); };
      println!("Starting 'cargo' with args: {:?}", args.join(" "));
      spawn_process(
        "cargo",
        args.as_slice(),
        MINER,
        "failed to run cargo r -p miner",
      )
    };

    let pid = &child.id();
    self.save_pid(MINER, *pid);
    println!("Started with PID {} in the background", pid);
  }

  /// Save PID
  pub fn save_pid(&mut self, proc_name: &str, pid: u32) {
    // Handle empty case
    match proc_name {
      "node" => {
        self.vitals.node_proc = create_or_insert(&mut self.vitals.node_proc, proc_name, pid);
      }
      "miner" => {
        self.vitals.miner_proc = create_or_insert(&mut self.vitals.miner_proc, proc_name, pid);
      }

      "monitor" => {
        self.vitals.monitor_proc = create_or_insert(&mut self.vitals.miner_proc, proc_name, pid);
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
}
