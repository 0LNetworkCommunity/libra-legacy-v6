//!  A simple workflow tool to organize all genesis
//! instead of using many CLI tools.

use anyhow::bail;
use dialoguer::{Confirm, Input};

use diem_genesis_tool::{
    key::{Key, OperatorKey, OwnerKey},
    validator_config::ValidatorConfig,
    validator_operator::ValidatorOperator,
};

use diem_github_client;
use diem_types::chain_id::ChainId;
use diem_types::network_address::{NetworkAddress, Protocol};
use dirs;
use indicatif::{ProgressBar, ProgressIterator};
use ol::config::AppCfg;
use ol_types::OLProgress;
use std::path::PathBuf;
use std::str::FromStr;
use std::{path::Path, thread, time::Duration};
// use ol::mgmt::restore::Backup;

use crate::run;

#[test]
fn test_wizard() {
    let mut wizard = GenesisWizard::default();
    wizard.start_wizard().unwrap();
}
/// Wizard for genesis
pub struct GenesisWizard {
    ///
    pub namespace: String,
    ///
    pub repo_owner: String,
    ///
    pub repo_name: String,
    github_username: String,
    github_token: String,
    data_path: PathBuf,
    ///
    pub epoch: u64,
}

impl Default for GenesisWizard {
    /// testnet values for genesis wizard
    fn default() -> Self {
        let data_path = dirs::home_dir().expect("no home dir found").join(".0L/");

        Self {
            namespace: "alice".to_string(),
            repo_owner: "0l-testnet".to_string(),
            repo_name: "dev-genesis".to_string(),
            github_username: "".to_string(),
            github_token: "".to_string(),
            data_path,
            epoch: 0, // What should this default value be?
        }
    }
}
impl GenesisWizard {
    /// start wizard for end-to-end genesis
    pub fn start_wizard(&mut self) -> anyhow::Result<()> {
        let to_genesis = Confirm::new()
            .with_prompt("Skip registration, straight to genesis?")
            .interact()
            .unwrap();

        // check if .0L folder is clean
        if !to_genesis {
            let has_data_path = Path::exists(&self.data_path);

            // initialize app configs
            if !has_data_path {
                println!("Let's initialize this host");

                initialize_host()?;
            } else {
                // check if the user wants to overwrite configs
                match Confirm::new()
                    .with_prompt("Want to freshen configs at .0L now?")
                    .interact()
                {
                    Ok(true) => initialize_host()?,
                    _ => {}
                }
            }

            // check if the user has the github auth token, and that
            // there is a forked repo on their account.
            // Fork the repo, if it doesn't exist
            self.git_setup()?;

            let app_config = ol_types::config::parse_toml(self.data_path.join("0L.toml"))?;

            // Run registration
            // register the configs on the new forked repo, and make the pull request
            self.register_configs(&app_config)?;

            self.make_pull_request()?
        }

        let ready = Confirm::new()
            .with_prompt("WAIT for everyone to do genesis. Is everyone ready?")
            .interact()
            .unwrap();

        if ready {
            // run genesis
            let snapshot_path = ol_types::fixtures::get_test_snapshot();
            // ${SOURCE}/ol/fixtures/rescue/state_backup/state_ver_76353076.a0ff
            run::default_run(
                self.data_path.clone(),
                snapshot_path,
                self.repo_owner.clone(),
                self.repo_name.clone(),
                self.github_token.clone(),
                false,
            )?;

            // create the files

            // empty the DB

            // verify genesis

            // reset the safety rules

            // remove "owner" key from key_store.json

            for _ in (0..10)
                .progress_with_style(OLProgress::fun())
                .with_message("Initializing 0L")
            {
                thread::sleep(Duration::from_millis(100));
            }
        } else {
          println!("Please wait for everyone to finish genesis and come back");
        }

        Ok(())
    }

    fn git_setup(&mut self) -> anyhow::Result<()> {
        let gh_token_path = self.data_path.join("github_token.txt");
        if !Path::exists(&gh_token_path) {
            println!("no github token found");
            match Input::<String>::new()
                .with_prompt("No github token found, enter one now, or save to github_token.txt:")
                .interact_text()
            {
                Ok(s) => {
                    std::fs::write(&gh_token_path, s)?;
                }
                _ => println!("somehow couldn't read what you typed "),
            }
        }

        self.github_token = std::fs::read_to_string(&gh_token_path)?;

        let gh_client = diem_github_client::Client::new(
            self.repo_owner.clone(),
            self.repo_name.clone(),
            "master".to_string(),
            self.github_token.clone(),
        );

        // Use the github token to find out who is the user behind it.
        self.github_username = gh_client.get_authenticated_user()?;

        if !Confirm::new()
            .with_prompt(format!(
                "Is this your github user? {} ",
                &self.github_username
            ))
            .interact()?
        {
            println!("Please update your github token");
            return Ok(());
        }

        // check if a gitbhub repo was already created.
        let user_gh_client = diem_github_client::Client::new(
            self.github_username.clone(),
            self.repo_name.clone(),
            "master".to_string(),
            self.github_token.clone(),
        );

        if user_gh_client.get_branches().is_err() {
            match Confirm::new()
                .with_prompt(format!(
                    "Fork the genesis repo to your account? {} ",
                    &self.github_username
                ))
                .interact()
            {
                Ok(true) => gh_client.fork_genesis_repo(&self.repo_owner, &self.repo_name)?,
                _ => bail!("no forked repo on your account, we need it to continue"),
            }
        } else {
            println!("Found a genesis repo on your account, we'll use that for registration.\n");
        }
        // Remeber to clear out the /owner key from the key_store.json for safety.
        Ok(())
    }

    fn register_configs(&self, app_cfg: &AppCfg) -> anyhow::Result<()> {
        let pb = ProgressBar::new(4).with_style(OLProgress::bar());

        // These are abstractions for github and the local key storage.
        let val = Key::validator_backend(
            app_cfg.format_oper_namespace().clone(),
            self.data_path.clone(),
        )?;

        let owner_shared = Key::shared_backend(
            app_cfg.format_owner_namespace().clone(),
            self.github_username.clone(), // NOTE: we need to write to the github user.
            self.repo_name.clone(),
            self.data_path.clone(),
        )?;

        let oper_shared = Key::shared_backend(
            app_cfg.format_oper_namespace().clone(),
            self.github_username.clone(), // NOTE: we need to write to the github user.
            self.repo_name.clone(),
            self.data_path.clone(),
        )?;



        //   # OPER does this
        // # Submits operator key to github, and creates local OPERATOR_ACCOUNT
        // oper-key:
        // 	cargo run -p diem-genesis-tool ${CARGO_ARGS} -- operator-key \
        // 	--validator-backend ${LOCAL} \
        // 	--shared-backend ${REMOTE}

        pb.inc(1);
        pb.set_message("registering the OWNER account.");

        let own = OwnerKey {
            key: Key::new(&val, &owner_shared),
        };

        own.execute()?;


        pb.set_message("registering the OPERATOR account.");
        let op = OperatorKey {
            key: Key::new(&val, &oper_shared),
        };

        op.execute()?;


        // # OWNER does this
        // # Submits operator key to github, does *NOT* create the OWNER_ACCOUNT locally
        // owner-key:
        // 	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  owner-key \
        // 	--validator-backend ${LOCAL} \
        // 	--shared-backend ${REMOTE}

        pb.inc(1);
        pb.set_message("registering the OPERATOR account.");
        let set_oper =
            ValidatorOperator::new(app_cfg.format_owner_namespace().clone(), &owner_shared);

        set_oper.execute()?;


        // # OWNER does this
        // # Links to an operator on github, creates the OWNER_ACCOUNT locally
        // assign:
        // 	cargo run -p diem-genesis-tool ${CARGO_ARGS} --  set-operator \
        // 	--operator-name ${OPER} \
        // 	--shared-backend ${REMOTE}

        pb.inc(1);
        pb.set_message("registering the validator configs.");
        let val_config = ValidatorConfig::new(
            app_cfg.format_owner_namespace().clone(),
            NetworkAddress::from_str(&*format!(
                "{}{}",
                Protocol::Ip4(app_cfg.profile.ip),
                Protocol::Tcp(6180)
            ))
            .unwrap(),
            NetworkAddress::from_str(&*format!(
                "{}{}",
                Protocol::Ip4(app_cfg.profile.vfn_ip.unwrap()),
                Protocol::Tcp(6179)
            ))
            .unwrap(),
            &oper_shared,
            &val,
            false,
            ChainId::new(app_cfg.chain_info.chain_id.id()),
        );
        val_config.execute()?;
        pb.inc(1);

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

        pb.finish_and_clear();
        OLProgress::complete("Registered configs on github");
        
        Ok(())
    }

    // fn restore_snapshot(&self, epoch: u64) -> anyhow::Result<()> {
    //     let pb = ProgressBar::new(1)
    //     .with_style(OLProgress::bar());

    //     // We need to initialize the abscissa application state for this to work.. Else it panics
    //     // TODO: fix panic of Backup::new().

    //     println!("Downloading snapshot for epoch {}", epoch);
    //     // All we are doing is download the snapshot from github.
    //     let backup = Backup::new(Option::from(epoch));
    //     println!("Created backup object");
    //     backup.fetch_backup(false)?;
    //     println!("Downloaded snapshot for epoch {}", epoch);

    //     pb.inc(1);
    //     pb.finish_and_clear();
    //     Ok(())
    // }

    fn make_pull_request(&self) -> anyhow::Result<()> {
        let gh_token_path = self.data_path.join("github_token.txt");
        let api_token = std::fs::read_to_string(&gh_token_path)?;

        let pb = ProgressBar::new(1).with_style(OLProgress::bar());
        let gh_client = diem_github_client::Client::new(
            self.repo_owner.clone(),
            self.repo_name.clone(),
            "master".to_string(),
            api_token.clone(),
        );
        // repository_owner, genesis_repo_name, username
        // This will also fail if there already is a pull request!
        match gh_client.make_genesis_pull_request(
            &*self.repo_owner,
            &*self.repo_name,
            &*self.github_username,
        ) {
            Ok(_) => println!("created pull request to genesis repo"),
            Err(_) => println!("failed to create pull request to genesis repo: do you already have an open PR? If so, you don't need to do anything else."),
        };
        pb.inc(1);
        pb.finish_and_clear();
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
