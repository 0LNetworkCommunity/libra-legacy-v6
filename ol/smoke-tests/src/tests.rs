use anyhow::{Context, Result};
use smoke_test::{
    smoke_test_environment::new_local_swarm,
    test_utils::{assert_balance, create_and_fund_account}, 
    operational_tooling::launch_swarm_with_op_tool_and_backend,
};
use diem_global_constants::{OWNER_ACCOUNT, OWNER_KEY, CONFIG_FILE};
use diem_rest_client::dpn::diem_root_address;
use diem_types::{
    account_address::AccountAddress,
    chain_id::NamedChain,
    account_state_blob::AccountStateBlob,
    on_chain_config::OnChainConfig,
};
use diem_sdk::types::{LocalAccount, AccountKey};
use forge::{NodeExt, Swarm, self};
use std::{time::{Duration, Instant}, convert::TryFrom};
use diem_secure_storage::CryptoStorage;
use diem_secure_storage::KVStorage;


use std::{
    path::PathBuf,
    process::Command,
};
use serde::{Deserialize, Serialize};
use diem_wallet::{Mnemonic, WalletLibrary};
use ol_types::fixtures::{
    get_persona_mnem,
    get_persona_block_one,
    get_persona_block_zero,
    get_persona_account_json,
};

#[derive(Clone, Debug, Eq, PartialEq, Serialize, Deserialize)]
struct ValidatorUniverse {
    validators: Vec<AccountAddress>,
}

impl OnChainConfig for ValidatorUniverse {
    const IDENTIFIER: &'static str = "ValidatorUniverse";
}

#[derive(Debug, Deserialize)]
struct Metadata {
    pub workspace_root: PathBuf,
}

fn metadata() -> Result<Metadata> {
    let output = Command::new("cargo")
        .args(&[
            "metadata",
            "--no-deps",
            "--format-version=1",
        ])
        .output()
        .context("Failed to query cargo metadata")?;

    serde_json::from_slice(&output.stdout).map_err(Into::into)
}

struct TestEnvionement {
    metadata: Metadata,
    swarm: forge::LocalSwarm,
    // op_tool: diem_operational_tool::test_helper::OperationalTool,
    // backend: diem_config::config::SecureBackend,
    storage: diem_secure_storage::Storage,
    env: String,
}

impl TestEnvionement {
    async fn new() -> TestEnvionement {
        let env = if std::env::var("NODE_ENV") == Ok("test".to_string()) { "test" } else { "stage" };
        let metadata = metadata().unwrap();
        let (
            swarm,
            _op_tool,
            _backend,
            storage
        ) = launch_swarm_with_op_tool_and_backend(1).await;

        TestEnvionement {
            metadata,
            swarm,
            // op_tool,
            // backend,
            storage,
            env: env.to_string(),
        }
    }

    fn get_persona_wallet(&self, persona: &str) -> WalletLibrary {
        let mnemonic = get_persona_mnem(persona);
        let mnem = Mnemonic::from(&mnemonic).unwrap();

        let mut wallet = WalletLibrary::new_from_mnemonic(mnem);
        wallet.generate_addresses(1).unwrap();

        wallet
    }

    async fn fund_account(&mut self, recipient: &LocalAccount) {
        let owner_account = self.storage
            .get::<AccountAddress>(OWNER_ACCOUNT)
            .unwrap()
            .value;

        let keys = self.storage.export_private_key(OWNER_KEY).unwrap();
        let sending_account = LocalAccount::new(
            owner_account,
            keys,
            0,
        );

        self.swarm.chain_info().ol_create_account_by_coin(sending_account, &recipient).await.unwrap();
    }

    async fn get_validator_universe(&mut self) -> Result<ValidatorUniverse> {
        let validator = self.swarm.validators().next().unwrap();
        let rpc_client = validator.json_rpc_client();

        let account_state = rpc_client
            .get_account_state_with_proof(
                diem_root_address(),
                None,
                None,
            )?
            .into_inner();

        let blob = account_state
            .blob.unwrap();
        let account_state_blob = AccountStateBlob::from(bcs::from_bytes::<Vec<u8>>(&blob)?);

        let account_state = diem_types::account_state::AccountState::try_from(&account_state_blob)?;
        let validator_universe = account_state.get_config::<ValidatorUniverse>()?;

        Ok(validator_universe.unwrap())
    }

    async fn create_validator_account(&mut self, persona: &str) -> Result<()> {
        let new_account = get_persona_account_json(persona);
        let new_account = serde_json::from_str(&new_account.0).expect("invalid account file");

        let owner_account = self.storage.get::<AccountAddress>(OWNER_ACCOUNT).unwrap().value;

        let keys = self.storage.export_private_key(OWNER_KEY)?;
        let local_acct = LocalAccount::new(owner_account, keys, 0);
        self.swarm
            .chain_info()
            .create_validator(
                local_acct,
                new_account
            )
            .await?;

        Ok(())
    }
}


#[tokio::test]
async fn ol_test_demo() {
    let (mut swarm, _op_tool, _backend, storage) = launch_swarm_with_op_tool_and_backend(1).await;
    let owner_account = storage.get::<AccountAddress>(OWNER_ACCOUNT).unwrap().value;
    let keys = storage.export_private_key(OWNER_KEY).unwrap();
    let mut local_acct = LocalAccount::new(owner_account, keys, 0);
    swarm.chain_info().ol_send_demo_tx(&mut local_acct).await.unwrap();
}

#[tokio::test]
async fn ol_test_create_account() {
    // create swarm
    let (mut swarm, _op_tool, _backend, storage) = launch_swarm_with_op_tool_and_backend(1).await;

    let client = swarm.validators().next().unwrap().rest_client();
    // get the localaccount type for the first validator (which is the only account on the swarm chain)
    let owner_account = storage.get::<AccountAddress>(OWNER_ACCOUNT).unwrap().value;
    let keys = storage.export_private_key(OWNER_KEY).unwrap();
    let local_acct = LocalAccount::new(owner_account, keys, 0);

    // create a random account.
    let new_account = LocalAccount::generate(&mut rand::rngs::OsRng);

    swarm.chain_info().ol_create_account_by_coin(local_acct, &new_account).await.unwrap();

    assert_balance(&client, &new_account, 1000000).await;
}

#[tokio::test]
async fn ol_test_create_and_fund() {
    let mut swarm = new_local_swarm(1).await;
    let client = swarm.validators().next().unwrap().rest_client();

    let mut c = swarm.chain_info();
    let root = c.root_account();
    assert_balance(&client, root, 10000000).await;

    let account_0 = create_and_fund_account(&mut swarm, 100).await;

    assert_balance(&client, &account_0, 100).await;
}

#[tokio::test]
async fn ol_test_basic_restartability() {
    let mut swarm = new_local_swarm(4).await;
    let validator = swarm.validators_mut().next().unwrap();
    validator.restart().await.unwrap();
    validator
        .wait_until_healthy(Instant::now() + Duration::from_secs(10))
        .await
        .unwrap();
    dbg!("validator healthy");
    let client = validator.rest_client();
    swarm.chain_info().ol_send_demo_tx_root(Some(client)).await.expect("could not send tx");
    dbg!("tx sent");  
}

/// Tests mining by sending proofs
///   - Initialize a local chain
///   - Create the miner's account (alice)
///   - Send the proofs (ol/fixtures/vdf_proofs/test/alice)
#[tokio::test]
async fn ol_test_mining() {
    let mut test_environment = TestEnvionement::new().await;

    let persona = "alice";

    let mut wallet = test_environment.get_persona_wallet(persona);
    wallet.generate_addresses(1).unwrap();
    let address = wallet.get_addresses().unwrap().into_iter().next().unwrap();
    let private_key = wallet.get_private_key(&address).unwrap();
    let account_key = AccountKey::from_private_key(private_key);
    let new_account = LocalAccount::new(address, account_key, 0);

    test_environment.fund_account(&new_account).await;

    let validator = test_environment.swarm.validators().next().unwrap();
    let rpc_client = validator.json_rpc_client();

    match rpc_client.get_miner_state(address) {
        Err(err) => {
            let err = err.json_rpc_error().unwrap();
            assert_eq!(err.message, "Server error: could not get tower state");
        },
        _ => {
            panic!("miner state for new account shouldn't exists");
        },
    }

    // Proof #0
    let proof = get_persona_block_zero(persona, &test_environment.env);
    test_environment.swarm.chain_info().ol_commit_proof(new_account, proof).await.unwrap();

    let miner_state = rpc_client.get_miner_state(address).unwrap();
    let miner_state = miner_state.inner().as_ref().unwrap();

    assert_eq!(miner_state.verified_tower_height, 0);

    // Proof #1
    let private_key = wallet.get_private_key(&address).unwrap();
    let account_key = AccountKey::from_private_key(private_key);
    let new_account = LocalAccount::new(address, account_key, 1);

    let proof = get_persona_block_one(persona, &test_environment.env);
    test_environment.swarm.chain_info().ol_commit_proof(new_account, proof).await.unwrap();

    let miner_state = rpc_client.get_miner_state(address).unwrap();
    let miner_state = miner_state.inner().as_ref().unwrap();

    assert_eq!(miner_state.verified_tower_height, 1);
}

/// Tests the mining capacity through the tower binary.
///   - Initialize a local chain
///   - Create the miner's account (alice)
///   - Send the proofs with tower (ol/fixtures/vdf_proofs/test/alice)
#[tokio::test]
async fn ol_test_tower_mining() {
    let mut test_environment = TestEnvionement::new().await;

    let validator = test_environment.swarm.validators().next().unwrap();
    let rpc_client = validator.json_rpc_client();

    // 01. CREATE MINER ACCOUNT
    let persona = "alice";
    let mut wallet = test_environment.get_persona_wallet(persona);
    wallet.generate_addresses(1).unwrap();
    let address = wallet.get_addresses().unwrap().into_iter().next().unwrap();

    let private_key = wallet.get_private_key(&address).unwrap();
    let account_key = AccountKey::from_private_key(private_key);
    let new_account = LocalAccount::new(address, account_key, 0);

    test_environment.fund_account(&new_account).await;

    // 02. FORGE TOWER CONFIG
    let mut rpc_url = rpc_client.url();
    rpc_url.set_path("");

    let waypoint = rpc_client.get_waypoint().unwrap();
    let waypoint = waypoint.inner().as_ref().unwrap();

    let mut config = ol_types::config::AppCfg::default();

    config.workspace.block_dir = test_environment.metadata.workspace_root.join(
        format!(
            "ol/fixtures/vdf_proofs/{}/{}",
            test_environment.env,
            persona
        )
    ).to_string_lossy().to_string();

    config.profile.account = address;

    config.chain_info.base_waypoint = Some(waypoint.waypoint);
    config.chain_info.chain_id = NamedChain::from_chain_id(&test_environment.swarm.chain_id()).unwrap();

    let mut rpc_url = rpc_client.url();
    rpc_url.set_path("");
    config.profile.upstream_nodes = vec![rpc_url];

    let node_home = test_environment.swarm.dir().join("tower");
    config.workspace.node_home = node_home.to_owned();

    config.save_file().unwrap();

    let tower_config_path = node_home.join(CONFIG_FILE).into_os_string().into_string().unwrap();

    // 03. SEND PROOFS
    let mnemonic = get_persona_mnem(persona);
    let mut process = Command::new("cargo")
        .env("TEST", "y")
        .env("MNEM", mnemonic.clone())
        .args(&[
            "run",
            "-p",
            "tower",
            "--",
            "--config",
            &tower_config_path,
            "backlog",
            "-s",
        ])
        .spawn()
        .expect("failed to execute process");

    process.wait().unwrap();

    let miner_state = rpc_client.get_miner_state(address).unwrap();
    let miner_state = miner_state.inner().as_ref().unwrap();

    assert_eq!(miner_state.verified_tower_height, 1);
}

/// Tests the validator onboarding
///   - Initialize a local chain
///   - Create the validator's account (alice) by calling AccountScripts::create_acc_val
///   - Check that the validator is in the validator set by checking the validator universe
#[tokio::test]
async fn ol_test_validator_onboarding() {
    let mut test_environment = TestEnvionement::new().await;

    let persona = "alice";

    let wallet = test_environment.get_persona_wallet(persona);
    let address = wallet.get_addresses().unwrap().into_iter().next().unwrap();

    let validator_universe = test_environment.get_validator_universe().await.unwrap();
    assert_eq!(validator_universe.validators.contains(&address), false);

    test_environment.create_validator_account(persona).await.unwrap();

    let validator_universe = test_environment.get_validator_universe().await.unwrap();
    assert_eq!(validator_universe.validators.contains(&address), true);
}