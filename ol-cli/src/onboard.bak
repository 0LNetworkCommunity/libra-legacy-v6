//! `onboard` 

// TODO: move to state_machine.rs?
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

/// TODO: Just check node.yaml, miner.toml, key_store.json or?
fn configs_exist() -> bool {
    use libra_global_constants::NODE_HOME;    
    // ~/.0L/
    let config_path = dirs::home_dir().unwrap().as_path().join(NODE_HOME);
    config_path.join("node.yaml").exists() 
}

///
fn run_validator_wizard() -> bool {
    println!("Running validator wizard");
    // TODO: where to get this path from?
    let miner_path = "/libra/target/debug/miner";
    let mut miner = std::process::Command::new(miner_path)
                        .arg("val-wizard")
                        .arg("--skip-mining")
                        .spawn()
                        .expect(&format!("failed to start {}", miner_path));

    let exit_code = miner.wait().expect("failed to wait on miner"); 
    assert!(exit_code.success());

    true
}

///
pub fn onboard() {
    println!("\n--- Onboarding Started");
    if !configs_exist() { run_validator_wizard(); }

    println!("\n--- Onboarding Complete!");
}

///
pub fn state_machine_demo() {
    println!("\n--- NodeState demo:");

    use NodeState::*;

    let sm = Machine::new(NoConfigs);
    println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger());

    let sm = sm.transition(CreateConfigs);
    println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());

    let sm = sm.transition(RestoreDb);
    println!("state: {:?} (trigger: {:?})", sm.state(), sm.trigger().unwrap());
}