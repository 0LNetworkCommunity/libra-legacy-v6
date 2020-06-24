use crate::executor::FakeExecutor;
use crate::account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier};
use crate::redeem::{redeem_txn, redeem_initialize_txn};
use ol_miner::delay::delay;
use libra_types::transaction::TransactionStatus;
use libra_types::vm_error::{VMStatus, StatusCode};
use hex;

#[test]
fn submit_proofs_transaction() {
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();

    let account = Account::new_genesis_account(libra_types::on_chain_config::config_address() );
    let sequence_number = 10u64;
    let sender = AccountData::with_account(
        account,
        1_000_000,
        lbr_currency_code(),
        sequence_number,
        AccountTypeSpecifier::Empty
    );

    executor.add_account_data(&sender);

    println!("address:{:?}", sender.address() );

    // let initialization_output = executor.execute_and_apply(
    //     // TODO: Describe what is happening here. What are we initializing?
    //     redeem_initialize_txn(&sender.account(), sequence_number)
    // );
    // assert_eq!(
    //     initialization_output.status(),
    //     &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    // );

    // test data for the VDF proof
    // let challenge = b"test preimage";
    // let difficulty = 100;
    // // use a test pre image and a 100 difficulty

    let challenge = b"aa";
    let difficulty = 100;
    // Generate solutions with cd ./verfiable-delay/ cargo run -- -l=4096 aa 100
    // the -l=4096 is important because this is the security paramater of 0L miner.
    let proof_computed = delay::do_delay(challenge, difficulty);

    let proof = hex::decode("005c9ee73ddaa19d050bc9944ac9ae5a16043fda1d0b20bfce0f7e18c1f7608eafb1e25b1fcf1e55cef3728bdcc695ecd51dcfafe297aa35a945d47e7b20266f501b0b7f636cd85f82a40cff7b57dfa96a521ff49f6daee00e65e1f44634443b818c088f40ef8dcb6cf4b0bdef336dd4c51aca0d6100e0acdcbd9bf26891a92e501bed6809762e0825624c82fbc38a692eac18457c0d74c126cfb62bdb665ee51a812758fc702865798b9f9cdb8d8236d068192f3f99df988f5ea55206353e0a54ca763350aae3ee10f4188c607e426fc52e7aa122b7df4b18cf2d0d50e964e3a721d83d4b9fee3090414965dfce75cd74c96fedcc269bc6baaf2a218865f1e63bffb02ac54d3e03d9018ec05a383a8b6acfc30d5e14db766d6cf01d5bc01a53ea9c0e55438b6eb9c3eba10682787aa1f57f75dfe69763e905b330b21bb6c8c0fb29327fe2085cfcbff7dd564e32ec2bcec261786d9598590c9abde29a96da79b56bb7bf171b413d3cd24b31b70df6b6488dd3cc4a5b26adced63f9e791b59c9ff3d7efff3fea92198d287287fd4f8f7b39917a6b7d8a53d4406bf41479560135deab1921c760b9480f16de2466bdbbb9ddd1a4fb2ea8f9378850064ba71ce01ea93f74aefb1bb7687c6cfc6f7fa8e492d611ac4a19a18309eb860d2c7b5f574b8d1b38132738946a5bbbb767352d58d2de16365e813665aa9921a9edec49dacabe500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001").unwrap();
    assert_eq!(proof_computed, proof.to_vec());

    //run the transaction script
    let output = executor.execute_and_apply(
        // build the transaction script binary.
        redeem_txn(&sender.account(), sequence_number, challenge.to_vec(), difficulty, proof.to_vec())
    );

    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );
}
