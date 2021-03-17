//! `sm` 

///
pub mod node_state_machine {
    sm::sm! {
        NodeState {
            InitialStates { EmptyBox }

            // Actions
            FastForwardDb { EmptyBox        => DbFastForwarded }
            Start         { DbFastForwarded => Started         }
            Sync          { Started         => Synced          }
            Clean         { DbFastForwarded => EmptyBox        }
        }
    }

    ///
    pub fn demo() {
        println!("\n--- NodeState demo:");

        use NodeState::*;

        let sm = Machine::new(EmptyBox);
        println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger());
    
        let sm = sm.transition(FastForwardDb);
        println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());
    
        let sm = sm.transition(Start);
        println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());
    }    
}

///
pub mod miner_state_machine {
    sm::sm! {
        MinerState {
            InitialStates { NotRunning }

            // Actions
            Run   { NotRunning => Running }
            Mine  { Running    => Mining  }
        }
    }

    ///
    pub fn demo() {
        println!("\n--- MinerState demo:");

        use MinerState::*;
        let sm = Machine::new(NotRunning);
        println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger());
    
        let sm = sm.transition(Run);
        println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());
    
        let sm = sm.transition(Mine);
        println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());
    }
}