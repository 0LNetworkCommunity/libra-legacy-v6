//! 'transition'

use crate::{
    check::{Check, DB_CACHE},
    management,
    restore,
};
use serde::{Serialize, Deserialize};

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
    /// Validator has fallen out of validator set, likely cannot sync, should change to fullnode mode.
    ValOutOfSet,
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
    /// Notify the fullnode lost sync
    FullnodeLostSync,
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
    /// get state
    pub fn get_state(&self) -> NodeVariants {
        self.state.to_owned()
    }

    /// trigger
    pub fn transition(&mut self, action: NodeAction, trigger_action: bool) -> &Self {        
        match action {
            NodeAction::Init => {}
            // node has an empty box, no config files
            NodeAction::RunWizard => {
                if self.state == NodeVariants::EmptyBox {self.state = NodeVariants::ValConfigsOk;}
            }

            NodeAction::RestoreDb => {
                if self.state == NodeVariants::ValConfigsOk {self.state = NodeVariants::DbRestoredOk;}
            }
            // Forward
            NodeAction::StartFullnode => {
                if self.state == NodeVariants::DbRestoredOk {self.state = NodeVariants::FullnodeIsRunning;}

                // if the node was previously in validator mode.
                if self.state == NodeVariants::ValidatorIsRunning || self.state ==  NodeVariants::ValOutOfSet {self.state = NodeVariants::FullnodeIsRunning;}
 
            }

            //Forward
            NodeAction::FullnodeSynced => {
                if self.state == NodeVariants::FullnodeIsRunning {self.state = NodeVariants::FullnodeSyncComplete};
            }

            NodeAction::FullnodeLostSync => {
                if self.state == NodeVariants::FullnodeSyncComplete {self.state = NodeVariants::FullnodeIsRunning};
            }

            NodeAction::SwitchToValidatorMode => {
                if self.state == NodeVariants::FullnodeSyncComplete {self.state = NodeVariants::ValidatorIsRunning};
            }

            //Forward
            NodeAction::ValidatorDroppedFromSet => {
                if self.state == NodeVariants::ValidatorIsRunning {self.state = NodeVariants::ValOutOfSet};
            }
        };
        self.maybe_advance(trigger_action);
        self
    }

    /// Advance to the next stage
    pub fn maybe_advance(&mut self, trigger_action: bool) -> &Self {
        dbg!("maybe advance");
        dbg!(&self.state);
        let check = Check::new();
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
                if check.database_bootstrapped() {&self.transition(NodeAction::RestoreDb, trigger_action);}
                else { 
                    println!("Onboarding: no state changes");
                    if trigger_action {
                        println!("Triggering expected action");
                        restore::fast_forward_db().expect("unable to fast forward db");
                    }
                }
                // self.state = NodeVariants::DbRestoredOk;
            }
            NodeVariants::DbRestoredOk => {
                self.state = NodeVariants::FullnodeIsRunning;
            }
            NodeVariants::FullnodeIsRunning => {
                self.state = NodeVariants::FullnodeSyncComplete;

            }
            NodeVariants::FullnodeSyncComplete => {
                self.state = NodeVariants::ValidatorIsRunning;

            }
            _ => {}
        };
        self
    }
}
