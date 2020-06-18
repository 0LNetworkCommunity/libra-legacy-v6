use crate::executor::FakeExecutor;
use crate::account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier};
use crate::redeem::{redeem_txn, redeem_initialize_txn};
use ol_miner::delay::delay;
use libra_types::transaction::TransactionStatus;
use libra_types::vm_error::{VMStatus, StatusCode};

#[test]
fn submit_proofs_transaction() {
    // TODO: This is using the Fake Executor, like all the other e2e tests. Is there a way to use a libra-swarm node?
    let mut executor = FakeExecutor::from_genesis_file();

    let account = Account::new_genesis_account(libra_types::on_chain_config::config_address() );
    let sequence_number = 10u64;
    let sender = AccountData::with_account(
        account, 1_000_000,
        lbr_currency_code(),sequence_number, AccountTypeSpecifier::Empty);
    executor.add_account_data(&sender);

    println!("address:{:?}", sender.address() );

    let initialization_output = executor.execute_and_apply(
        // TODO: Describe what is happening here. What are we initializing?
        redeem_initialize_txn(&sender.account(), sequence_number)
    );
    assert_eq!(
        initialization_output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );

    // test data for the VDF proof
    let challenge = b"test preimage";
    let difficulty = 100;
    // use a test pre image and a 100 difficulty
    let proof = delay::do_delay(challenge, difficulty);

    //run the transaction script
    let output = executor.execute_and_apply(
        // build the transaction script binary.
        redeem_txn(&sender.account(), sequence_number+1u64, challenge.to_vec(), difficulty, proof)
    );

    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );
}
