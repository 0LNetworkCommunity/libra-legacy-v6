//! 'transitions' a state machine for the onboarding stages of a new validator. Can query and/or trigger the next expected action in the onboarding process.

use crate::{
    check::{DB_CACHE, Check},
    management,
    restore,
};
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
    /// Notify the validatro was dropped from set.
    ValidatorDroppedFromSet,

}

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// The Current state of a node
pub struct NodeState {
    state: NodeVariants,
    trigger: NodeAction,
    // check: Check,
}

impl NodeState {
    /// init
    pub fn init() -> Self{
        Self {
            state: NodeVariants::EmptyBox,
            trigger: NodeAction::Init,
            // check: Check::new(),
        }
    }

    /// Saves the Items to cache
    pub fn write_cache(&self) {
        let serialized = serde_json::to_vec(&self.clone()).unwrap();
        match DB_CACHE.put("onboarding", serialized) {
            Ok(_) => {}
            Err(err) => {dbg!(&err);}
        }; 
    }
    
    /// Get from cache
    pub fn read_cache() -> Option<NodeState>{
        let q = DB_CACHE.get("onboarding").unwrap().unwrap();
        match serde_json::from_slice(&q.as_slice()) {
            Ok(items) => {
                Some(items)
            }
            Err(_) => {None}
        }
    }

    /// Get state
    pub fn get_state(&self) -> NodeVariants {
        self.state.to_owned()
    }

    /// State transition
    pub fn transition(&mut self, action: NodeAction, trigger_action: bool) -> &Self {        
        use NodeVariants::*;
        match action {
            NodeAction::Init => {}

            // Node has an empty box, no config files
            NodeAction::RunWizard => {
                if self.state == EmptyBox {self.state = ValConfigsOk;}
            }

            NodeAction::RestoreDb => {
                if self.state == ValConfigsOk {self.state = DbRestoredOk;}
            }
            
            // Forward
            NodeAction::StartFullnode => {
                if self.state == DbRestoredOk {self.state = FullnodeIsRunning;}

                // if the node was previously in validator mode
                if self.state == ValidatorIsRunning || self.state == ValidatorOutOfSet {
                    self.state = FullnodeIsRunning;
                }
 
            }

            // Forward
            NodeAction::FullnodeSynced => {
                if self.state == FullnodeIsRunning {self.state = FullnodeSyncComplete};
            }

            NodeAction::SwitchToValidatorMode => {
                if self.state == FullnodeSyncComplete {self.state = ValidatorIsRunning};
            }

            //Forward
            NodeAction::ValidatorDroppedFromSet => {
                if self.state == ValidatorIsRunning {self.state = ValidatorOutOfSet};
            }
        };

        self.maybe_advance(trigger_action);
        self
    }

    /// Advance to the next state
    pub fn maybe_advance(&mut self, trigger_action: bool) -> &Self {
        dbg!(&self.state);
        let mut check = Check::new();
        match &self.state {
            NodeVariants::EmptyBox => {
                if check.configs_exist() {
                    &self.transition(NodeAction::RunWizard, trigger_action);}
                else { 
                    println!("Onboarding: no state changes");
                    if trigger_action {
                        println!("Triggering expected action");
                        management::run_validator_wizard();
                    }
                };
            }
            NodeVariants::ValConfigsOk => {
                if check.database_bootstrapped() {
                    &self.transition(NodeAction::RestoreDb, trigger_action);
                } else { 
                    println!("Onboarding: no state changes");
                    if trigger_action {
                        println!("Triggering expected action");
                        restore::fast_forward_db().expect("unable to fast forward db");
                    }
                }
            }
            NodeVariants::DbRestoredOk => {
                if check.node_running() {
                    &self.transition(NodeAction::StartFullnode, trigger_action);
                } else { 
                    println!("Onboarding: no state changes");
                    if trigger_action {
                        println!("Triggering expected action");
                        management::start_node(
                            management::NodeType::Fullnode
                        ).expect("unable to start fullnode");
                    }
                }
            }
            // TODO: Miner should have own separate state machine
            // If fullnode is running try to mine (if account is created)
            NodeVariants::FullnodeIsRunning => {
                // start miner but don't advance.
                // advance only when in sync
                if check.accounts_exist_on_chain() && !check.miner_running() {
                    management::start_miner()
                }

                if check.check_sync() {
                    &self.transition(NodeAction::FullnodeSynced, trigger_action);
                } else { 
                    println!("Onboarding: no state changes");
                    // Nothing to do to make fullnode sync, just waiting
                }
            }
            // TODO: would be unusual if the validator joined val set before 
            //       the fullnode is synced, but could happen.

            // if node sync is complete, can check if is in validator set, and 
            // switch to validator mode.
            NodeVariants::FullnodeSyncComplete => {
                if check.is_in_validator_set() {
                    &self.transition(NodeAction::SwitchToValidatorMode, trigger_action);
                } else { 
                    println!("Onboarding: no state changes");
                    // Nothing to do to make fullnode sync, just waiting

                    // TODO: Do we need to stop node, or is the process killing correct?
                    management::start_node(
                        management::NodeType::Validator
                    ).expect("unable to start node in validator mode");
                }

            }
            _ => {}
        };
        
        self
    }
}
