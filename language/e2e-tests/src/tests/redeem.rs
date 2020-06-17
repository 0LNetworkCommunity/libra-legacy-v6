use crate::executor::FakeExecutor;
use crate::account::{Account, AccountData, lbr_currency_code, AccountTypeSpecifier};
use crate::redeem::{redeem_txn, redeem_initialize_txn};
use ol_miner::delay::delay;
use libra_types::transaction::TransactionStatus;
use libra_types::vm_error::{VMStatus, StatusCode};

#[test]
fn submit_proofs() {
    // create a FakeExecutor with a genesis from file
    // We can't run mint test on terraform genesis as we don't have the private key to sign the
    // mint transaction.
    let mut executor = FakeExecutor::from_genesis_file();

    let sender = AccountData::with_account(
        Account::new_association(), 1_000_000,
        lbr_currency_code(),10, AccountTypeSpecifier::Empty);
    executor.add_account_data(&sender);

    println!("address:{:?}", sender.address() );

    let oi = executor.execute_and_apply(
        redeem_initialize_txn(&sender.account(), 10)
    );
    assert_eq!(
        oi.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );

    let challenge = b"test preimage";
    let difficulty = 100;
    // use a test pre image and a 100 difficulty
    let proof = delay::do_delay(challenge, difficulty);

    let output = executor.execute_and_apply(
        redeem_txn(&sender.account(), 11, challenge.to_vec(), difficulty, proof)
    );

    assert_eq!(
        output.status(),
        &TransactionStatus::Keep(VMStatus::new(StatusCode::EXECUTED))
    );

}