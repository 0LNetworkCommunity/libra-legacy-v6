script {
    use 0x0::GAS;
    // use 0x0::Libra;
    use 0x0::LibraAccount;
    // use 0x0::Transaction;
    use 0x0::TransactionFee;
    use 0x0::Debug;

    fun main(amt: u64) {
        TransactionFee::distribute_transaction_fees_internal<GAS::T>(amt);
        
        let bal = LibraAccount::balance<GAS::T>(0xFEE);
        Debug::print(&0xBA1);
        Debug::print(&bal);
        Debug::print(&amt);
    }
}