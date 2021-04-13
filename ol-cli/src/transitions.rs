//! 'transitions' a state machine for the onboarding stages of a new validator. Can query and/or trigger the next expected action in the onboarding process.

use std::process::Command;

use crate::{cache::DB_CACHE, entrypoint, management, node_health::NodeHealth, prelude::app_config, restore};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]

/// States the account can be in
pub enum AccountState {
  /// doesn't exist on chain
  None,
  /// account created on chain
  ExistsOnChain
}


/// Events that can be taken on accounts
pub enum AccountEvents {
  /// initialized
  Configured,
  /// account created
  Created
}
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// All states a node can be in
pub enum OnboardState {
  /// Nothing is configured
  EmptyBox,
  /// Files initialized node.yaml, key_store.json
  ValConfigsOk,
  /// Database restored from backup
  DbRestoredOk,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// All actions which can be taken on a node
pub enum OnboardEvents {
  /// Initialize the onboarding state
  Init,
  /// Create files by running wizard
  RunWizard,
  /// Restore the DB from state backups
  RestoreDb,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// States the node can be in
pub enum NodeState {
  /// Stopped
  Stopped,
  /// Node is running in fullnode mode, but has not synced
  FullnodeModeCatchup,
  /// Database is in sync, as fullnode
  FullnodeMode,
  /// Node is running in validator mode
  ValidatorMode,
  /// Validator has fallen out of validator set, likely cannot sync,
  /// should change to fullnode mode.
  ValidatorOutOfSet,
}



/// Events that can be taken on a node
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub enum NodeEvents {
  /// Start the fullnode
  StartFullnode,
  /// Notify the fullnode has synced
  FullnodeSynced,
  /// Restart the node in validator mode
  SwitchToValidatorMode,
  /// Notify the validator was dropped from set.
  ValidatorDroppedFromSet,
  /// Rejoin set
  RejoinValidatorSet,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// All states a miner can be in
pub enum MinerState {
  /// Miner connected to upstream
  Stopped,
  /// Miner connected to upstream
  Mining,
}
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// Actions that impact the miner
pub enum MinerEvents {
  /// miner has started
  Started,
  /// miner failed
  Failed,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// The Current state of a node
pub struct HostState {
  /// state of onboarding
  onboard_state: OnboardState,
  /// state of node
  node_state: NodeState,
  /// state of miner
  miner_state: MinerState,
  // trigger: OnboardEvents,
}

/// methods for host state
impl HostState {
  /// init
  pub fn init() -> Self {
    Self {
      onboard_state: OnboardState::EmptyBox,
      node_state: NodeState::Stopped,
      miner_state: MinerState::Stopped,

      // trigger: OnboardEvents::Init,
      // check: Check::new(),
    }
  }

  /// Saves the Items to cache
  pub fn write_cache(&self) {
    let serialized = serde_json::to_vec(&self.clone()).unwrap();
    match DB_CACHE.put("onboarding", serialized) {
      Ok(_) => {}
      Err(err) => {
        dbg!(&err);
      }
    };
  }

  /// Get from cache
  pub fn read_cache() -> Option<HostState> {
    let q = DB_CACHE.get("onboarding").unwrap().unwrap();
    match serde_json::from_slice(&q.as_slice()) {
      Ok(items) => Some(items),
      Err(_) => None,
    }
  }

  /// Get state
  pub fn get_state(&self) -> (OnboardState, NodeState, MinerState) {
    (self.onboard_state.clone(), self.node_state.clone(), self.miner_state.clone())
  }

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
      MinerEvents::Started => self.miner_state = MinerState::Mining,
      MinerEvents::Failed => self.miner_state = MinerState::Stopped,
    };
    self
  }

  /// try to advance the state machine
  pub fn miner_maybe_advance(&mut self, trigger_action: bool) -> &Self {
    let mut check = NodeHealth::new();

    match &self.miner_state {
      // MinerState::EmptyBox => {
      //     if check.configs_exist() {
      //         &self.miner_transition(MinerEvents::RanWizard, trigger_action);
      //     }
      //     // Note: Don't trigger any action, may conflict with validator node setup.
      // }
      // MinerState::ConfigsOk => {
      //     if check.accounts_exist_on_chain() {
      //         &self.miner_transition(MinerEvents::AccountCreated, trigger_action);
      //     }
      // }
      // MinerState::AccountOnChain => {
      //     if check.miner_running() {
      //         &self.miner_transition(MinerEvents::Started, trigger_action);
      //     } else {
      //         // if the node has synced (or is otherwise advanced in onboaring)
      //         match &self.node_state {
      //             OnboardState::FullnodeSyncComplete => management::start_miner(),
      //             OnboardState::ValidatorIsRunning => management::start_miner(),
      //             OnboardState::ValidatorOutOfSet => management::start_miner(),
      //             _ => {}
      //         }
      //     }
      // }
      MinerState::Mining => {
        if !check.miner_running() {
          &self.miner_transition(MinerEvents::Failed, trigger_action);
        }
      }
      MinerState::Stopped => {
        if check.miner_running() {
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
  pub fn onboard_transition(&mut self, action: OnboardEvents, trigger_action: bool) -> &Self {
    use OnboardState::*;
    match action {
      OnboardEvents::Init => {}

      // Node has an empty box, no config files
      OnboardEvents::RunWizard => {
        if self.onboard_state == EmptyBox {
          self.onboard_state = ValConfigsOk;
        }
      }

      OnboardEvents::RestoreDb => {
        if self.onboard_state == ValConfigsOk {
          self.onboard_state = DbRestoredOk;
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
        if self.node_state == Stopped {
          self.node_state = FullnodeModeCatchup;
        }

        // if the node was previously in validator mode
        if self.node_state == ValidatorMode || self.node_state == ValidatorOutOfSet {
          self.node_state = FullnodeMode;
        }
      }

      NodeEvents::FullnodeSynced => {
        if self.node_state == FullnodeModeCatchup {
          self.node_state = FullnodeMode
        };
      }

      NodeEvents::SwitchToValidatorMode => {
        if self.node_state == FullnodeMode {
          self.node_state = ValidatorMode
        };
      }

      NodeEvents::ValidatorDroppedFromSet => {
        if self.node_state == ValidatorMode {
          self.node_state = ValidatorOutOfSet
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
    let mut check = NodeHealth::new();
    
    let entry_args = entrypoint::get_args();
    let cfg = app_config();
    // Try to advance the node state. Miner below
    match &self.onboard_state {
      OnboardState::EmptyBox => {
        if check.configs_exist() {
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
        if check.database_bootstrapped() {
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
    let mut check = NodeHealth::new();
    
    let entry_args = entrypoint::get_args();
    let cfg = app_config();
    // Try to advance the node state. Miner below
    match &self.node_state {
      // TODO: Miner should have own separate state machine
      // If fullnode is running try to mine (if account is created)
      NodeState::FullnodeModeCatchup => {
        if NodeHealth::node_is_synced().0 {
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
        if check.is_in_validator_set() {
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
