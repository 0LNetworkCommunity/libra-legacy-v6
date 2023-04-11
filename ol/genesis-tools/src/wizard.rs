//!  A simple workflow tool to organize all genesis
//! instead of using many CLI tools.

use anyhow::bail;
use dialoguer::{Confirm, Input};

use diem_genesis_tool::{
    key::{Key, OperatorKey, OwnerKey, reset_safety_data},
    storage_helper::StorageHelper,
    validator_config::ValidatorConfig,
    validator_operator::ValidatorOperator, verify::Verify,
    waypoint,
    ol_node_files
};

use diem_github_client;
use diem_types::chain_id::{ChainId, NamedChain};
use diem_types::network_address::{NetworkAddress, Protocol};
use dirs;
use indicatif::{ProgressBar, ProgressIterator};
use ol::config::AppCfg;
use ol::mgmt::restore::Backup;
use ol_types::OLProgress;
use std::str::FromStr;
use std::{fs, path::PathBuf};
use std::{path::Path, thread, time::Duration};
use diem_global_constants::{
 OPERATOR_KEY, OWNER_KEY,
};
use diem_secure_storage::KVStorage;
use ol::commands::init_cmd;
use crate::run;

#[test]
#[ignore]
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
    pub epoch: Option<u64>,
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
            epoch: None,
        }
    }
}
impl GenesisWizard {
    /// start wizard for end-to-end genesis
    pub fn start_wizard(&mut self) -> anyhow::Result<()> {
        // check the git token is as expected, and set it.
        self.git_token_check()?;

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
                if Confirm::new()
                    .with_prompt("Want to freshen configs at .0L now?")
                    .interact()?
                {
                   initialize_host()?;
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
            // assumes this environment is set up properly
            let app_config = ol_types::config::parse_toml(self.data_path.join("0L.toml"))?;
            // run genesis

            let snapshot_path = if Confirm::new()
                .with_prompt("Do we need to download a new legacy snapshot?")
                .interact()? {
                self.download_snapshot(&app_config)?
            } else {
                let input = Input::<String>::new()
                    .with_prompt("Enter the (absolute) path to the snapshot state.manifest file")
                    .interact_text()?;
                PathBuf::from(input)
            };
            println!("snapshot path: {:?}", snapshot_path);

            // do the whole genesis workflow and create the files
            run::default_run(
                self.data_path.clone(),
                snapshot_path,
                self.repo_owner.clone(),
                self.repo_name.clone(),
                self.github_token.clone(),
                false,
            )?;

            // make node files
            self.make_node_files(&app_config)?;

            // reset the safety rules
            reset_safety_data(&self.data_path, &app_config.format_oper_namespace());

            // check db
            self.maybe_backup_db();

            // remove "owner" key from key_store.json
            self.maybe_remove_money_keys(&app_config);

            // verify genesis
            self.check_keys_and_genesis(&app_config)?;

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

    fn git_token_check(&mut self) -> anyhow::Result<()> {
        let gh_token_path = self.data_path.join("github_token.txt");
        if !Path::exists(&gh_token_path) {
            match Input::<String>::new()
                .with_prompt("No github token found, enter one now, or save to github_token.txt")
                .interact_text()
            {
                Ok(s) => {
                    // creates the folders if necessary (this check is called before host init)
                    std::fs::create_dir_all(&self.data_path)?;
                    std::fs::write(&gh_token_path, s)?;
                }
                _ => println!("somehow couldn't read what you typed"),
            }
        }

        self.github_token = std::fs::read_to_string(&gh_token_path)?;
        OLProgress::complete("github token found");

        let temp_gh_client = diem_github_client::Client::new(
            self.repo_owner.clone(), // doesn't matter
            self.repo_name.clone(),
            "master".to_string(),
            self.github_token.clone(),
        );

        self.github_username = temp_gh_client.get_authenticated_user()?;

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

        Ok(())
    }

    fn git_setup(&mut self) -> anyhow::Result<()> {
        let gh_client = diem_github_client::Client::new(
            self.repo_owner.clone(),
            self.repo_name.clone(),
            "master".to_string(),
            self.github_token.clone(),
        );

        // Use the github token to find out who is the user behind it
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

    fn maybe_remove_money_keys(&self, app_cfg: &AppCfg) {
        if Confirm::new()
            .with_prompt("Remove the money keys from the key store?")
            .interact().unwrap()
        {
            let storage_helper =
                StorageHelper::get_with_path(self.data_path.clone());

            let mut owner_storage = storage_helper.storage(app_cfg.format_oper_namespace().clone());
            owner_storage.set(OWNER_KEY, "").unwrap();
            owner_storage.set(OPERATOR_KEY, "").unwrap();

            let mut oper_storage = storage_helper.storage(app_cfg.format_oper_namespace().clone());

            oper_storage.set(OWNER_KEY, "").unwrap();
            oper_storage.set(OPERATOR_KEY, "").unwrap();
        }
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
        // The oper key is saved locally as key + -oper. This little hack works..
        let set_oper =
            ValidatorOperator::new(app_cfg.format_oper_namespace(), &owner_shared);
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

    fn check_keys_and_genesis(&self, app_cfg: &AppCfg) -> anyhow::Result<String> {
        let val = Key::validator_backend(
            app_cfg.format_owner_namespace().clone(),
            self.data_path.clone(),
        )?;

      let v = Verify::new(&val,self.data_path.join("genesis.blob"));
      Ok(v.execute()?)
    }

    fn download_snapshot(&mut self, app_cfg: &AppCfg) -> anyhow::Result<PathBuf> {
        if let Some(e) = self.epoch {
            if !Confirm::new()
                .with_prompt(&format!("So are we migrating data from epoch {}?", e))
                .interact()
                .unwrap()
            {
                bail!("Please specify the epoch you want to migrate from.")
            }
        } else {
            self.epoch = Input::new()
                .with_prompt("What epoch are we migrating from? ")
                .interact_text()
                .ok();
            // .map(|epoch| epoch.parse().unwrap()).ok();
        }

        let pb = ProgressBar::new(1000).with_style(OLProgress::spinner());

        pb.enable_steady_tick(Duration::from_millis(100));

        // All we are doing is download the snapshot from github.
        let backup = Backup::new(self.epoch, app_cfg);

        if backup.manifest_path().is_err() {
            backup.fetch_backup(true)?;
        } else {
            println!("Already have snapshot for epoch {}", self.epoch.unwrap());
        }

        // I changed the manifest file name to state.manifest instead of epoch_ending.manifest
        let snapshot_manifest_file = backup.manifest_path()?;

        let snapshot_dir = snapshot_manifest_file.parent().unwrap().to_path_buf();

        pb.finish_and_clear();
        Ok(snapshot_dir)
    }

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

    fn maybe_backup_db(&self) {
        // ask to empty the DB
        if self.data_path.join("db").exists() {
            println!("We found a /db directory. Can't do genesis with a non-empty db.");
            if Confirm::new()
                .with_prompt("Let's move the old /db to /db_bak_<date>?")
                .interact().unwrap()
            {
                let date_str = chrono::Utc::now().format("%Y-%m-%d-%H-%M").to_string();
                fs::rename(
                    self.data_path.join("db"),
                    self.data_path.join(format!("db_bak_{}", date_str)),
                ).expect("failed to move db to db_bak");
            }
        }
    }

    fn make_node_files(&self, app_cfg: &AppCfg) -> anyhow::Result<()> {
        // create the files necessary to run the node
        let waypoint = waypoint::extract_waypoint_from_file(
            &self.data_path.join("genesis.blob")
        )?;
        println!("waypoint: {:?}", waypoint);
        fs::write(self.data_path.join("genesis_waypoint.txt"), waypoint.to_string())?;


        init_cmd::update_waypoint(&mut app_cfg.clone(), Option::from(waypoint), None)?;

        // make extract-waypoint && cargo r -p ol -- init --update-waypoint --waypoint $(shell cat ${DATA_PATH}/genesis_waypoint.txt)
        //
        // 1. cargo run -p diem-genesis-tool ${CARGO_ARGS} -- create-waypoint \
        // 	--genesis-path ${DATA_PATH}/genesis.blob \
        // 	--extract \
        // 	--chain-id ${CHAIN_ID} \
        // 	--shared-backend ${REMOTE} \
        // 	| awk -F 'Waypoint: '  '{print $$2}' > ${DATA_PATH}/genesis_waypoint.txt\

        // 2. cargo r -p ol -- init --update-waypoint --waypoint $(shell cat ${DATA_PATH}/genesis_waypoint.txt)

        ol_node_files::onboard_helper_all_files(
            self.data_path.clone(),
            NamedChain::MAINNET,
            Some(self.repo_owner.clone()),
            Some(self.repo_name.clone()),
            &app_cfg.format_oper_namespace(),
            &Some(self.data_path.join("genesis.blob")),
            &false,
            None,
            &None,
            Some(app_cfg.profile.ip))?;

        // node-files:
        //     cargo run -p diem-genesis-tool ${CARGO_ARGS} -- files \
        // --chain-id ${CHAIN_ID} \
        // --validator-backend ${LOCAL} \
        // --data-path ${DATA_PATH} \
        // --namespace ${ACC}-oper \
        // --genesis-path ${DATA_PATH}/genesis.blob \
        // --val-ip-address ${IP} \

        // rm -rf ~/.0L/db
        Ok(())
    }

}

fn initialize_host() -> anyhow::Result<AppCfg> {
    let mut w = onboard::wizard::OnboardWizard::default();
    w.genesis_ceremony = true;

    w.run()
}

