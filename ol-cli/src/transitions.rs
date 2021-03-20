//! 'transition'

use crate::check::DB_CACHE;
use serde::{Serialize, Deserialize};


// #[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
// #[serde(deny_unknown_fields)]
// struct Transition {
//     action: NodeTrans,
//     from: NodeState,
//     to: NodeState,
//     // trigger: Fn // function from check.rs
// }

///
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub enum NodeVariants {
    EmptyBox,
    ValConfigsOk,
    DbRestoredOk,
    FullnodeStarted,
    FullnodeSyncComplete,
    ValidatorModeRunning,
    ValidatorInSync
}

///
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub enum NodeTrans {
    Init,
    RunWizard,
    WipeConfigs
}

///
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
pub struct NodeState {
    state: NodeVariants,
    trigger: NodeTrans,
}


impl NodeState {
    /// init
    pub fn init() -> Self{
        Self {
            state: NodeVariants::EmptyBox,
            trigger: NodeTrans::Init,
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
    pub fn get_state(self) -> NodeVariants {
        self.state
    }

    /// trigger
    pub fn trigger(mut self, trigger: NodeTrans) -> Self {        
        match trigger {
            NodeTrans::Init => {}
            // node has an empty box, no config files
            NodeTrans::RunWizard => {
                if self.state == NodeVariants::EmptyBox {self.state = NodeVariants::ValConfigsOk;}
            }
            // revert
            NodeTrans::WipeConfigs => {
                if self.state == NodeVariants::ValConfigsOk {self.state = NodeVariants::EmptyBox;}
            }

            //             // start fullnode, to sync
            // FullnodeSync { StateDbRestoredOk => StateFullnodeStarted}
            // // reverse
            // StopFullnodeSync { StateFullnodeStarted => StateDbRestoredOk}

            // // when sync is complete
            // FullnodeInSync { StateFullnodeStarted => StateFullnodeSyncComplete}
            // // reverse, the node falls
            // FullnodeLostSync { StateFullnodeSyncComplete => StateFullnodeStarted}

            // // switch to validator mode if sync is complete
            // SwitchValidatorMode { StateFullnodeSyncComplete => StateValidatorModeRunning }
            // // reverse, failed to enter validator mode, node failed to start
            // FallbackFullnode { StateValidatorModeSwitch => StateFullnodeSyncComplete }

            // // validator in sync
            // ValidatorInSync { StateValidatorModeRunning => StateValidatorInSync}

            // // // Validator mode can lose sync
            // // ValidatorLostSync { StateValidatorInSync => StateValidatorModeLostSync }
            
            // // Validator mode can lose sync, drops all the way back to FullnodeStated
            // ValidatorDroppedFromSet { StateValidatorInSync => StateFullnodeStarted }
        };
        self
    }

    /// Advance to the next stage
    pub fn override_forward(mut self) -> Self {
        match self.state {
            NodeVariants::EmptyBox => {
                self.state = NodeVariants::ValConfigsOk;
            },
            NodeVariants::ValConfigsOk => {
                self.state = NodeVariants::DbRestoredOk;
            },
            NodeVariants::DbRestoredOk => {
                self.state = NodeVariants::FullnodeStarted;
            },
            NodeVariants::FullnodeStarted => {
                self.state = NodeVariants::FullnodeSyncComplete;

            },
            NodeVariants::FullnodeSyncComplete => {
                self.state = NodeVariants::ValidatorModeRunning;

            },
            NodeVariants::ValidatorModeRunning => {
                self.state = NodeVariants::ValidatorInSync;

            }
            _ => {}
        };
        self
    }
}
