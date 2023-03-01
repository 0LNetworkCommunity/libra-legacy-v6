//!  A simple workflow tool to organize all genesis
//! instead of using many CLI tools.



use anyhow::bail;
use dialoguer::{Confirm, Input};

use diem_genesis_tool::{
  validator_operator::ValidatorOperator,
  key::{OperatorKey, Key, OwnerKey}
};

use indicatif::{ProgressIterator, ProgressBar};
use ol::config::AppCfg;
use std::{path::Path, thread, time::Duration};
use dirs;
use ol_types::OLProgress;
use diem_github_client;
use std::path::PathBuf;


#[test]
fn test_wizard() {
  let wizard = GenesisWizard::default();
  wizard.start_wizard().unwrap();
}

pub struct GenesisWizard {
  pub namespace: String,
  pub repo_owner: String,
  pub repo_name: String,
  github_username: String,
  github_token: String,
  data_path: PathBuf,
}

impl Default for GenesisWizard {
  /// testnet values for genesis wizard
  fn default() -> Self {
    let data_path = dirs::home_dir().expect("no home dir found").join(".0L/");
    dbg!(&data_path);
    Self {
      namespace: "alice".to_string(),
      repo_owner: "0l-testnet".to_string(),
      repo_name: "dev-genesis".to_string(),
      github_username: "".to_string(),
      github_token: "".to_string(),
      data_path
    }
  }
}
impl GenesisWizard {
  /// start wizard for end-to-end genesis
pub fn start_wizard(&mut self) -> anyhow::Result<()>{

  Confirm::new()
    .with_prompt("Let's do this?")
    .interact()
    .unwrap();

  // check if .0L folder is clean

  let has_data_path = Path::exists(&self.data_path);

  // initialize app configs
  if !has_data_path {
    println!("Let's initialize this host");
    
    initialize_host()?;

  } else {
  // check if the user wants to overwrite configs
    match Confirm::new()
      .with_prompt("Want to freshen configs at .0L now?")
      .interact() {
        Ok(true) => initialize_host()?,
        _ => {},
    }
  }

  // check if the user has the github auth token, and that
  // there is a forked repo on their account.
  self.git_setup()?;

  let app_config = ol_types::config::parse_toml(self.data_path.join("0L.toml"))?;


  // register the configs on the new forked repo, and make the pull request
  self.register_configs(&app_config)?;


  for _ in (0..10).progress_with_style(OLProgress::fun())
    .with_message("Initializing 0L") {
    thread::sleep(Duration::from_millis(100));
  }



  // Fork the repo, if it doesn't exist

  // Run registration

  // run genesis

  // create the files

  // empty the DB

  // reset the safety rules

  // verify genesis

  Ok(())
}

fn git_setup(&mut self) -> anyhow::Result<()> {
    let gh_token_path = self.data_path.join("github_token.txt");
  if !Path::exists(&gh_token_path) {
      println!("no github token found");
      match Input::<String>::new()
        .with_prompt("No github token found, enter one now, or save to github_token.txt:")
        .interact_text() {
          Ok(s) => {
            std::fs::write(&gh_token_path, s)?;
          },
          _ => println!("somehow couldn't read what you typed "),
    } 
  }

  let api_token = std::fs::read_to_string(&gh_token_path)?;

  let gh_client = diem_github_client::Client::new(
    self.repo_owner.clone(),
    self.repo_name.clone(),
    "master".to_string(),
    api_token.clone(),
  );

  // Use the github token to find out who is the user behind it.
  self.github_username =  gh_client.get_authenticated_user()?;

  if !Confirm::new()
    .with_prompt(format!("Is this your github user? {} ", &self.github_username))
    .interact()? {
      println!("Please update your github token");
      return Ok(());
    }
  

  // check if a gitbhub repo was already created.
  let user_gh_client = diem_github_client::Client::new(
    self.github_username.clone(),
    self.repo_name.clone(),
    "master".to_string(),
    api_token,
  );

  if user_gh_client.get_branches().is_err() {
    match Confirm::new()
    .with_prompt(format!("Fork the genesis repo to your account? {} ", &self.github_username))
    .interact() {
        Ok(true) =>  gh_client.fork_genesis_repo(&self.repo_owner, &self.repo_name)?,
        _ => bail!("no forked repo on your account, we need it to continue"),
    }
  } else {
    println!("found a genesis repo on your account, we'll use that for registration");
  }
  // Remeber to clear out the /owner key from the key_store.json for safety.
  Ok(())

}

 fn register_configs(&self, app_cfg: &AppCfg) -> anyhow::Result<()>{
    let pb = ProgressBar::new(4)
    .with_style(OLProgress::bar());
    


  // These are abstractions for github and the local key storage.
  let val = Key::validator_backend(
     app_cfg.format_oper_namespace().clone(), 
     self.data_path.clone()
  )?;

  let sh = Key::shared_backend(
     app_cfg.format_owner_namespace().clone(), 
     self.repo_owner.clone(), 
     self.repo_name.clone(), 
     self.data_path.clone()
  )?;
  
  let op = OperatorKey {
    key: Key::new(&val, &sh)
  };

  op.execute()?;

  pb.inc(1);

  let own = OwnerKey {
    key: Key::new(&val, &sh)
  };

  own.execute()?;
  pb.inc(1);

  let set_oper = ValidatorOperator::new(
    app_cfg.format_owner_namespace().clone(),
    &sh
  );

  set_oper.execute()?;
  pb.inc(1);

  pb.finish_and_clear();

  //TODO(nima) send the validator config. similar to above
  
//   # OPER does this
// # Submits operator key to github, and creates local OPERATOR_ACCOUNT
// oper-key:
// 	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- operator-key \
// 	--validator-backend ${LOCAL} \
// 	--shared-backend ${REMOTE}

// # OWNER does this
// # Submits operator key to github, does *NOT* create the OWNER_ACCOUNT locally
// owner-key:
// 	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  owner-key \
// 	--validator-backend ${LOCAL} \
// 	--shared-backend ${REMOTE}

// # OWNER does this
// # Links to an operator on github, creates the OWNER_ACCOUNT locally
// assign: 
// 	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  set-operator \
// 	--operator-name ${OPER} \
// 	--shared-backend ${REMOTE}

// # OPER does this
// # Submits signed validator registration transaction to github.
// reg:
// 	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  validator-config \
// 	--owner-name ${OWNER} \
// 	--chain-id ${CHAIN_ID} \
// 	--validator-address "/ip4/${IP}/tcp/6180" \
// 	--fullnode-address "/ip4/${IP}/tcp/6179" \
// 	--validator-backend ${LOCAL} \
// 	--shared-backend ${REMOTE}

  Ok(())
 }

}



fn initialize_host() -> anyhow::Result<()> {
  let mut w = onboard::wizard::Wizard::default();
  w.genesis_ceremony = true;
  w.run()
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