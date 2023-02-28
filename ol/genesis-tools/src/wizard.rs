//!  workflow for genesis


use dialoguer::{Confirm, Input};
use std::path::Path;
use dirs;
use onboard::commands::wizard_val_cmd::ValWizardCmd;

#[test]
fn test_wizard() {
  start_wizard();
}

/// wizard for running genesis
pub fn start_wizard() {

  Confirm::new()
    .with_prompt("Let's do this?")
    .interact()
    .unwrap();

  let h = dirs::home_dir().expect("no home dir found");
  let has_data_path = Path::exists(&h.join(".0L/"));

  if !has_data_path {
    println!("let's initialize this host");
    
    let wiz_cmd = ValWizardCmd::default();
  }

  

  // Enter the path of your 0L folder
  // fs::
  // let input: String = Input::new()
  //   .with_prompt("Enter the full path to use (e.g. /home/name)")
  //   .interact_text()
  //   .unwrap();
  // check if we have a github token


  // Dialog: git username
  // stretch: check the token is useful on that account.

  // check if .0L folder is clean

  // initialize app configs

  // Fork the repo, if it doesn't exist

  // Run registration

  // run genesis

  // create the files

  // empty the DB

  // reset the safety rules

  // verify genesis

}



// # ENVIRONMENT
// # 1. You must have a github personal access token at ~/.0L/github_token.txt
// # 2. export the environment variable `GITHUB_USER=<your github username`


// # All nodes must initialize their configs.
// # You can optionally use the key generator to use a new account in this genesis.

// v6-keys:
// 	cargo r -p onboard -- keygen

// # Initialize basic files. Take advantage to build the stdlib, in case.
// v6-init: stdlib init

// # Each validator will have their own github REPO for the purposes of
// # Registering for genesis. THis repo is a fork of the coordinating repo.
// # Once registered (in next step), a pull request will be sent back to the original repo with 
// # the node's registration information.
// v6-github: gen-fork-repo

// # Each validator registers for genesis ON THEIR OWN GITHUB FORK.
// v6-register: gen-register

// # One person should write to the coordination repo with the list of validators.
// # or can be manually by pull request, changing set_layout.toml
// v6-validators: layout

// v6-genesis: fork-genesis 

// # Create the files necessary to start node. Includes new waypoint from genesis
// v6-files: set-waypoint node-files 
// 	# DESTROYING DB
// 	rm -rf ~/.0L/db

// # Verify the local configuration and the genesis.
// v6-verify: verify-gen