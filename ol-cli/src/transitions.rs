//! 'transition'

use crate::check::DB_CACHE;
use serde::{Serialize, Deserialize};


#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
struct Transition {
    action: NodeTrans,
    from: NodeState,
    to: NodeState,
    // trigger: Fn // function from check.rs
}

///
#[derive(Clone, Debug, Deserialize, Serialize)]
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

#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub enum NodeTrans {
    Init,
    RunWizard,
    WipeConfigs
}

///
#[derive(Clone, Debug, Deserialize, Serialize)]
#[serde(deny_unknown_fields)]
pub struct NodeState {
    state: NodeVariants,
    trigger: NodeTrans,
}


impl NodeState {
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
    // pub fn c
    pub fn get_state(self) -> NodeVariants {
        self.state
    }

    // pub fn transition(mut self, from: NodeVariants, to: NodeVariants, trigger: NodeTrans) -> Self {        
    //     if self.state == from {
    //         self.state = to;
    //         self.trigger = trigger;
    //     };
    //     self
    // }
    pub fn advance(mut self) -> Self {
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
    // pub fn allowed_transitions() Vec<Transition>{
    //     vec![
    //         Transition {
    //             action: NodeTrans::RunWizard,
    //             from: NodeState::EmptyBox,
    //             to: NodeState::ValConfigsOk,
    //             // trigger: Fn // function from check.rs
    //         }

    //     ]
    // }
}
