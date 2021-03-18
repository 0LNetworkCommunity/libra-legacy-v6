//! `onboard` 

/// TODO: move to state_machine.rs?
sm::sm! {
    NodeState {
        InitialStates { EmptyBox, NoConfigs }

        // Actions and States
        CreateConfigs { NoConfigs      => ConfigsCreated }
        RestoreDb     { ConfigsCreated => DbRestored     }
        CreateAccount { DbRestored     => AccountCreated }
        Sync          { AccountCreated => Synced         }
    }
}

///
pub fn demo() {
    println!("\n--- NodeState demo:");

    use NodeState::*;

    let sm = Machine::new(NoConfigs);
    println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger());

    let sm = sm.transition(CreateConfigs);
    println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());

    let sm = sm.transition(RestoreDb);
    println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());
}