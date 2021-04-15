//! 'transitions' a state machine for the onboarding stages of a new validator. Can query and/or trigger the next expected action in the onboarding process.

use std::process::Command;

use crate::{cache::DB_CACHE, entrypoint, management, node_health::NodeHealth, prelude::app_config, restore};
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// All states a node can be in
pub enum NodeVariants {
    /// Nothing is configured
    EmptyBox,
    /// Files initialized node.yaml, key_store.json
    ValConfigsOk,
    /// Database restored from backup
    DbRestoredOk,
    /// Node is running in fullnode mode
    FullnodeIsRunning,
    /// Database is in sync, as fullnode
    FullnodeSyncComplete,
    /// Node is running in validator mode
    ValidatorIsRunning,
    /// Validator has fallen out of validator set, likely cannot sync,
    /// should change to fullnode mode.
    ValidatorOutOfSet,
}
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// All actions which can be taken on a node
pub enum NodeAction {
    /// Initialize the onboarding state
    Init,
    /// Create files by running wizard
    RunWizard,
    /// Restore the DB from state backups
    RestoreDb,
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
pub enum MinerVariants {
    /// Nothing is configured
    EmptyBox,
    /// Files initialized  0L.toml, node.yaml, key_store.json
    ConfigsOk,
    /// Account exists on chain, and has balance, can start mining.
    AccountOnChain,
    /// Miner connected to upstream
    Mining,
    /// Miner connected to upstream
    Stopped,
}
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// Actions that impact the miner
pub enum MinerAction {
    /// wizard was run to create host configs
    RanWizard,
    /// account was created on chain
    AccountCreated,
    /// miner has started
    Started,
    /// miner failed
    Failed,
}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// The Current state of a node
pub struct HostState {
    node_state: NodeVariants,
    miner_state: MinerVariants,
    trigger: NodeAction,
}

impl HostState {
    /// init
    pub fn init() -> Self {
        Self {
            node_state: NodeVariants::EmptyBox,
            miner_state: MinerVariants::EmptyBox,
            trigger: NodeAction::Init,
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
    pub fn get_state(&self) -> NodeVariants {
        self.node_state.to_owned()
    }

    /// Get state
    pub fn get_next_action(&self) -> NodeAction {
        use NodeVariants::*;
        match self.node_state {
            EmptyBox => NodeAction::RunWizard,
            ValConfigsOk => NodeAction::RestoreDb,
            DbRestoredOk => NodeAction::StartFullnode,
            FullnodeIsRunning => NodeAction::FullnodeSynced,
            FullnodeSyncComplete => NodeAction::SwitchToValidatorMode,

            ValidatorIsRunning => NodeAction::ValidatorDroppedFromSet,
            ValidatorOutOfSet => NodeAction::RejoinValidatorSet,
        }
    }

    /// the transitions in the miner state machine
    pub fn miner_transition(&mut self, action: MinerAction, _trigger_action: bool) -> &Self {
        match action {
            MinerAction::RanWizard => self.miner_state = MinerVariants::ConfigsOk,
            MinerAction::AccountCreated => self.miner_state = MinerVariants::AccountOnChain,
            MinerAction::Started => self.miner_state = MinerVariants::Mining,
            MinerAction::Failed => self.miner_state = MinerVariants::Mining,
        };
        self
    }

    /// try to advance the state machine
    pub fn miner_maybe_advance(&mut self, trigger_action: bool) -> &Self {
        let mut check = NodeHealth::new();

        match &self.miner_state {
            MinerVariants::EmptyBox => {
                if check.configs_exist() {
                    &self.miner_transition(MinerAction::RanWizard, trigger_action);
                }
                // Note: Don't trigger any action, may conflict with validator node setup.
            }
            MinerVariants::ConfigsOk => {
                if check.accounts_exist_on_chain() {
                    &self.miner_transition(MinerAction::AccountCreated, trigger_action);
                }
            }
            MinerVariants::AccountOnChain => {
                if check.miner_running() {
                    &self.miner_transition(MinerAction::Started, trigger_action);
                } else {
                    // if the node has synced (or is otherwise advanced in onboaring)
                    match &self.node_state {
                        NodeVariants::FullnodeSyncComplete => management::start_miner(),
                        NodeVariants::ValidatorIsRunning => management::start_miner(),
                        NodeVariants::ValidatorOutOfSet => management::start_miner(),
                        _ => {}
                    }
                }
            }
            MinerVariants::Mining => {
                if !check.miner_running() {
                    &self.miner_transition(MinerAction::Failed, trigger_action);
                }
            }
            MinerVariants::Stopped => {
                if check.miner_running() {
                    &self.miner_transition(MinerAction::Started, trigger_action);
                } else {
                    // start the miner
                    management::start_miner();
                }
            }
        }
        self
    }

    /// State transition
    pub fn transition(&mut self, action: NodeAction, trigger_action: bool) -> &Self {
        use NodeVariants::*;
        match action {
            NodeAction::Init => {}

            // Node has an empty box, no config files
            NodeAction::RunWizard => {
                if self.node_state == EmptyBox {
                    self.node_state = ValConfigsOk;
                }
            }

            NodeAction::RestoreDb => {
                if self.node_state == ValConfigsOk {
                    self.node_state = DbRestoredOk;
                }
            }

            NodeAction::StartFullnode => {
                if self.node_state == DbRestoredOk {
                    self.node_state = FullnodeIsRunning;
                }

                // if the node was previously in validator mode
                if self.node_state == ValidatorIsRunning || self.node_state == ValidatorOutOfSet {
                    self.node_state = FullnodeIsRunning;
                }
            }

            NodeAction::FullnodeSynced => {
                if self.node_state == FullnodeIsRunning {
                    self.node_state = FullnodeSyncComplete
                };
            }

            NodeAction::SwitchToValidatorMode => {
                if self.node_state == FullnodeSyncComplete {
                    self.node_state = ValidatorIsRunning
                };
            }

            NodeAction::ValidatorDroppedFromSet => {
                if self.node_state == ValidatorIsRunning {
                    self.node_state = ValidatorOutOfSet
                };
            }
            NodeAction::RejoinValidatorSet => {}
        };

        // Keep advancing through the state machine
        self.maybe_advance(trigger_action);
        self
    }

    /// Advance to the next state
    pub fn maybe_advance(&mut self, trigger_action: bool) -> &Self {
        let mut check = NodeHealth::new();
        
        let entry_args = entrypoint::get_args();
        let cfg = app_config();
        // Try to advance the node state. Miner below
        match &self.node_state {
            NodeVariants::EmptyBox => {
                if check.configs_exist() {
                    &self.transition(NodeAction::RunWizard, trigger_action);
                } else {
                    if trigger_action {
                        action_print("attempting to run wizard");
                        management::run_validator_wizard();
                    } else {
                        println!("Config files not initialized, cannot advance.")
                    }
                };
            }
            NodeVariants::ValConfigsOk => {
                if check.database_bootstrapped() {
                    &self.transition(NodeAction::RestoreDb, trigger_action);
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
            NodeVariants::DbRestoredOk => {
                if check.node_running() {
                    &self.transition(NodeAction::StartFullnode, trigger_action);
                } else {
                    if trigger_action {
                        action_print("attempting to start node in fullnode mode");
                        management::start_node(management::NodeType::Fullnode)
                            .expect("unable to start fullnode");
                    } else {
                        println!("Node is not running, cannot advance.")
                    }
                }
            }
            // TODO: Miner should have own separate state machine
            // If fullnode is running try to mine (if account is created)
            NodeVariants::FullnodeIsRunning => {
                if NodeHealth::node_is_synced().0 {
                    &self.transition(NodeAction::FullnodeSynced, trigger_action);
                } else {
                    println!("Node is not synced, cannot advance.")
                }
            }
            // TODO: would be unusual if the validator joined val set before
            //       the fullnode is synced, but could happen.

            // if node sync is complete, can check if is in validator set, and
            // switch to validator mode.
            NodeVariants::FullnodeSyncComplete => {
                if check.is_in_validator_set() {
                    // Stop node first, then restart as validator.
                    management::stop_node();

                    management::start_node(management::NodeType::Validator)
                        .expect("unable to start node in validator mode");

                    &self.transition(NodeAction::SwitchToValidatorMode, trigger_action);
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
