//! 'transitions' a state machine for the onboarding stages of a new validator. Can query and/or trigger the next expected action in the onboarding process.

use std::process::Command;
use crate::{entrypoint, mgmt::{management, restore}, prelude::app_config};



use super::{node::Node, states::{MinerEvents, MinerState, NodeEvents, OnboardEvents, OnboardState, NodeState}};

impl Node {

  /// Saves the Items to cache
  // pub fn write_cache(&self) {
  //   let serialized = serde_json::to_vec(&self.clone()).unwrap();
  //   match DB_CACHE.put("onboarding", serialized) {
  //     Ok(_) => {}
  //     Err(err) => {
  //       dbg!(&err);
  //     }
  //   };
  // }

  /// Get from cache
  // pub fn read_cache() -> Option<HostState> {
  //   let q = DB_CACHE.get("onboarding").unwrap().unwrap();
  //   match serde_json::from_slice(&q.as_slice()) {
  //     Ok(items) => Some(items),
  //     Err(_) => None,
  //   }
  // }

  // /// Get state
  // pub fn get_next_action(&self) -> OnboardEvents {
  //     use OnboardState::*;
  //     match self.node_state {
  //         EmptyBox => OnboardEvents::RunWizard,
  //         ValConfigsOk => OnboardEvents::RestoreDb,
  //         DbRestoredOk => OnboardEvents::StartFullnode,
  //         FullnodeIsRunning => OnboardEvents::FullnodeSynced,
  //         FullnodeSyncComplete => OnboardEvents::SwitchToValidatorMode,

  //         ValidatorIsRunning => OnboardEvents::ValidatorDroppedFromSet,
  //         ValidatorOutOfSet => OnboardEvents::RejoinValidatorSet,
  //     }
  // }

  /// the transitions in the miner state machine
  pub fn miner_transition(&mut self, action: MinerEvents, _trigger_action: bool) -> &Self {
    match action {
      MinerEvents::Started => self.host_state.miner_state = MinerState::Mining,
      MinerEvents::Failed => self.host_state.miner_state = MinerState::Stopped,
    };
    self
  }

  /// try to advance the state machine
  pub fn miner_maybe_advance(&mut self, trigger_action: bool) -> &Self {
    match &self.host_state.miner_state {
      MinerState::Mining => {
        if !Node::miner_running() {
          &self.miner_transition(MinerEvents::Failed, trigger_action);
        }
      }
      MinerState::Stopped => {
        if Node::miner_running() {
          &self.miner_transition(MinerEvents::Started, trigger_action);
        } else {
          // start the miner
          management::start_miner();
        }
      }
    }
    self
  }

  /// State transition
  pub fn onboard_transition(&mut self, action: OnboardEvents, _trigger_action: bool) -> &Self {
    use OnboardState::*;
    match action {
      OnboardEvents::Init => {}

      // Node has an empty box, no config files
      OnboardEvents::RunWizard => {
        if self.host_state.onboard_state == EmptyBox {
          self.host_state.onboard_state = ValConfigsOk;
        }
      }

      OnboardEvents::RestoreDb => {
        if self.host_state.onboard_state == ValConfigsOk {
          self.host_state.onboard_state = DbRestoredOk;
        }
      }
      }
      self
    }

  /// State transition
  pub fn node_transition(&mut self, action: NodeEvents, trigger_action: bool) -> &Self {
    use NodeState::*;
    match action {
      NodeEvents::StartFullnode => {
        if self.host_state.node_state == Stopped {
          self.host_state.node_state = FullnodeModeCatchup;
        }

        // if the node was previously in validator mode
        if self.host_state.node_state == ValidatorMode || self.host_state.node_state == ValidatorOutOfSet {
          self.host_state.node_state = FullnodeMode;
        }
      }

      NodeEvents::FullnodeSynced => {
        if self.host_state.node_state == FullnodeModeCatchup {
          self.host_state.node_state = FullnodeMode
        };
      }

      NodeEvents::SwitchToValidatorMode => {
        if self.host_state.node_state == FullnodeMode {
          self.host_state.node_state = ValidatorMode
        };
      }

      NodeEvents::ValidatorDroppedFromSet => {
        if self.host_state.node_state == ValidatorMode {
          self.host_state.node_state = ValidatorOutOfSet
        };
      }
      NodeEvents::RejoinValidatorSet => {}
    };

    // Keep advancing through the state machine
    self.node_maybe_advance(trigger_action);
    self
  }

  /// Advance to the next state
  pub fn onboard_maybe_advance(&mut self, trigger_action: bool) -> &Self {    
    let entry_args = entrypoint::get_args();
    let cfg = app_config();
    // Try to advance the node state. Miner below
    match &self.host_state.onboard_state {
      OnboardState::EmptyBox => {
        if self.configs_exist() {
          &self.onboard_transition(OnboardEvents::RunWizard, trigger_action);
        } else {
          if trigger_action {
            action_print("attempting to run wizard");
            management::run_validator_wizard();
          } else {
            println!("Config files not initialized, cannot advance.")
          }
        };
      }
      OnboardState::ValConfigsOk => {
        if self.database_bootstrapped() {
          &self.onboard_transition(OnboardEvents::RestoreDb, trigger_action);
        } else {
          if trigger_action && entry_args.swarm_path.is_none() {
            action_print("attempting to restore db from archive");
            restore::fast_forward_db(false).expect("unable to fast forward db");
          } else if let Some(path) = entry_args.swarm_path {
            // swarm testing, mock restore
            // TODO: place waypoint in key_store, and node.yaml
              let db_path = path.join("0/db");
              Command::new("rsync")
              .arg("-r")
              .arg(db_path.to_str().unwrap())
              .arg(cfg.workspace.node_home.to_str().unwrap())
              .output()
              .expect("failed to execute rsync");

          } else {
            println!("Database not bootstrapped, cannot advance.")
          }
        }
      }
      OnboardState::DbRestoredOk => {
        // if check.node_running() {
        //   &self.onboard_transition(OnboardEvents::StartFullnode, trigger_action);
        // } else {
        //   if trigger_action {
        //     action_print("attempting to start node in fullnode mode");
        //     management::start_node(management::NodeType::Fullnode)
        //       .expect("unable to start fullnode");
        //   } else {
        //     println!("Node is not running, cannot advance.")
        //   }
        // }
      }
    };

    self
  }
    /// Advance to the next state
  pub fn node_maybe_advance(&mut self, trigger_action: bool) -> &Self {
    match &self.host_state.node_state {
      // If fullnode is running try to mine (if account is created)
      NodeState::FullnodeModeCatchup => {
        if self.is_synced().0 {
          &self.node_transition(NodeEvents::FullnodeSynced, trigger_action);
        } else {
          println!("Node is not synced, cannot advance.")
        }
      }
      // TODO: would be unusual if the validator joined val set before
      //       the fullnode is synced, but could happen.

      // if node sync is complete, can check if is in validator set, and
      // switch to validator mode.
      NodeState::FullnodeMode => {
        if self.is_in_validator_set() {
          // Stop node first, then restart as validator.
          management::stop_node();

          management::start_node(management::NodeType::Validator)
            .expect("unable to start node in validator mode");

          &self.node_transition(NodeEvents::SwitchToValidatorMode, trigger_action);
        } else {
          println!("Not in validator set, cannot advance.")
        }
        //No 'else'. Nothing to do to make fullnode sync, just waiting
      }
      _ => {}
    };

    self
  }
} 

fn action_print(action_text: &str) {
  println!("Triggering expected action: {}", action_text);
}
