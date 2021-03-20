//! `machine` 
// pub mod combined_state_machine {
//     use sm::Machine;
//     use sm::Transition;
//     use super::node_state_machine::export;
//     // use super::node_state_machine::NodeState::RunWizard;

//     pub fn test() {
//         let mac = export();
//         // let mac = mac.transition(RunWizard);
//         dbg!(&mac.state());
//     }
 

//         // let sm = Machine::new(StateEmptyBox);
//         // println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger());
    
//         // let sm = sm.transition(RunWizard);
//         // println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());
// }
// A state machine description for validator node onboarding

// pub mod node_state_machine {
    sm::sm! {
        NodeState {
            InitialStates { StateEmptyBox }

            // actions { state => state}
            // node has an empty box, no config files
            RunWizard { StateEmptyBox => StateValConfigsOk }
            // reverse the action
            WipeConfigs { StateValConfigsOk => StateEmptyBox }

            // node's database is not yet initialized. Restore the Db.
            RestoreDb { StateValConfigsOk => StateDbRestoredOk }
            // reverse
            WipeDatabase { StateDbRestoredOk => StateValConfigsOk }
            
            // start fullnode, to sync
            FullnodeSync { StateDbRestoredOk => StateFullnodeStarted}
            // reverse
            StopFullnodeSync { StateFullnodeStarted => StateDbRestoredOk}

            // when sync is complete
            FullnodeInSync { StateFullnodeStarted => StateFullnodeSyncComplete}
            // reverse, the node falls
            FullnodeLostSync { StateFullnodeSyncComplete => StateFullnodeStarted}

            // switch to validator mode if sync is complete
            SwitchValidatorMode { StateFullnodeSyncComplete => StateValidatorModeRunning }
            // reverse, failed to enter validator mode, node failed to start
            FallbackFullnode { StateValidatorModeSwitch => StateFullnodeSyncComplete }

            // validator in sync
            ValidatorInSync { StateValidatorModeRunning => StateValidatorInSync}

            // // Validator mode can lose sync
            // ValidatorLostSync { StateValidatorInSync => StateValidatorModeLostSync }
            
            // Validator mode can lose sync, drops all the way back to FullnodeStated
            ValidatorDroppedFromSet { StateValidatorInSync => StateFullnodeStarted }
        }

        MinerState {
            InitialStates { NoProofs }

            
            // Miner needs a synced database to start, will first start mining with upstream.
            MinerRemote { NoProofs => StateMinerRemote }
            // reverse
            FailedMinerRemote { StateMinerRemote => NoProofs }

            // proofs succeeded
            MinerRemoteTxSuccess { StateMinerRemote => StateMinerRemoteTxSuccess }
            
            // Miner has a local database to use, no longer needs remote
            LocalMinerStart { StateMinerRemoteSuccess => StateLocalMinerStarted }
            // reverse, failed to start local miner
            FailedLocalMiner { StateLocalMinerStarted => StateMinerRemoteSuccess }

            // Miner succeeds in submitting a proof using local db
            LocalMinerTxSuccess { StateLocalMinerStarted => StateLocalMinerTxSuccess }

        }
        UserState {
            InitialStates { UserStateNoAccount }

            // actions { state => state }
            // Starting from an empty box
            RunWizard { UserStateNoAccount => UserStateCreatedFiles }

            // submit an on-chain transaction with account.json
            SubmitTx { UserStateCreatedFiles => UserStateTransactionSubmitted }
            // account is created
            AccountCreated { UserStateTransactionSubmitted => UserStateAccountCreatedOk }
            // account has balance
            AccountHasBalance { UserStateAccountCreatedOk => UserStateAccountBalanceOk }

            // account has mined 
            Mining { UserStateAccountBalanceOk => UserStateMiningOk }
            // account has mined above threshold
            MiningAbove { UserStateMiningOk => UserStateMiningAboveThreshOk }

            // account has mined above threshold
            InValidatorSet{ UserStateMiningAboveThreshOk => UserStateInValidatorSet }
        }
    }

    /// Returns a starting state machine
    pub fn export() -> NodeState::Machine<NodeState::StateEmptyBox, sm::NoneEvent>{
        println!("\n--- NodeState demo:");
        pub use NodeState::{Machine, StateEmptyBox};
        
        Machine::new(StateEmptyBox)
    }

    // pub struct Test {}
    // impl Test {
    //     pub fn new() {
    //         use NodeState;
    //         let sm = NodeState::Machine::new(NodeState::StateEmptyBox);

    //         dbg!(&sm.state());

    //         dbg!(&sm.as_enum());
    //     }
    // }

    pub struct Autopilot {
        // state: sm::sm!()
    }
    impl Autopilot {
        pub fn new() -> Self{
            // use NodeState;
            use NodeState::Variant::*;
            let sm = NodeState::Machine::new(NodeState::StateEmptyBox);


            // dbg!(&sm.transition(NodeState));

            // dbg!(&sm.as_enum());
        }
        // pub fn advance(mut self) {
        //     self.sm.
        // }
        // pub fn match() {
        //     match &sm.state() {
        //         StateEmptyBox => {
        //             dbg!(&StateEmptyBox);
        //         }

        //     };
        // }
    }
// }