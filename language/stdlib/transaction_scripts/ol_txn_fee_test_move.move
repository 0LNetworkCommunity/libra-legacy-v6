script {
    // use 0x1::Libra;
    // use 0x1::LibraAccount;
    // use 0x1::Transaction;
    use 0x1::LibraSystem;
    // use 0x1::Debug;

    fun ol_txn_fee_test_move(account: &signer) {
        // mint a coin the association (tx sender)

        LibraSystem::distribute_transaction_fees(account);
    }
}