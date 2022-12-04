//! 'transitions' a state machine for the onboarding stages of a new validator. Can query and/or trigger the next expected action in the onboarding process.

use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// States the account can be in
pub enum AccountState {
    /// doesn't exist on chain
    None,
    /// account created on chain
    ExistsOnChain,
    /// account in val set
    InSet,
}

/// Events that can be taken on accounts
pub enum AccountEvents {
    /// initialized
    Configured,
    /// account created
    Created,
}
#[derive(Clone, Debug, Deserialize, Serialize, PartialEq)]
#[serde(deny_unknown_fields)]
/// All states a node can be in
pub enum OnboardState {
    /// Nothing is configured
    EmptyBox,
    /// Files initialized node.yaml, key_store.json
    ValConfigsOk,

    /// DB files
    DbFilesOk,
    /// Database restored from backup
    DbBootstrapOk,
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
pub enum TowerState {
    /// Miner stopped
    Stopped,
    /// Miner running
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
/// All states the web-monitor can be in
pub enum MonitorState {
    /// Monitor stopped
    Stopped,
    /// Monitor serving
    Serving,
}

#[derive(Clone, Debug, Deserialize, Serialize)]
/// The Current state of a node
pub struct HostState {
    /// state of onboarding
    pub onboard_state: OnboardState,
    /// state of node
    pub node_state: NodeState,
    /// state of miner
    pub miner_state: TowerState,
    /// state of monitor
    pub monitor_state: MonitorState,
    /// state of account
    pub account_state: AccountState,
}

/// methods for host state
impl HostState {
    /// init
    pub fn new() -> Self {
        Self {
            onboard_state: OnboardState::EmptyBox,
            node_state: NodeState::Stopped,
            miner_state: TowerState::Stopped,
            monitor_state: MonitorState::Stopped,
            account_state: AccountState::None,
        }
    }
}
