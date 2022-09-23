use smoke_test::{
    smoke_test_environment::new_local_swarm,
    test_utils::{assert_balance, create_and_fund_account}, 
    operational_tooling::launch_swarm_with_op_tool_and_backend,
};
use diem_global_constants::{OWNER_ACCOUNT, OWNER_KEY};
use diem_types::account_address::AccountAddress;
use diem_sdk::types::LocalAccount;
use forge::{NodeExt, Swarm};
use std::time::{Duration, Instant};
use diem_secure_storage::CryptoStorage;
use diem_secure_storage::KVStorage;

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