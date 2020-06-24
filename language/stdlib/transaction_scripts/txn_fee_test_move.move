script {
    use 0x0::GAS;
    // use 0x0::Libra;
    // use 0x0::LibraAccount;
    // use 0x0::Transaction;
    use 0x0::TransactionFee;
    // use 0x0::Debug;

    fun main() {
        // mint a coin the association (tx sender)

        TransactionFee::distribute_transaction_fees<GAS::T>();
    }
}