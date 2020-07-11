script {
    use 0x0::GAS;
    // use 0x0::Libra;
    use 0x0::LibraAccount;
    use 0x0::LibraSystem;
    use 0x0::Transaction;
    use 0x0::TransactionFee;
    use 0x0::Vector;

    fun main() {
        let i = 0;
        let num_vals = LibraSystem::validator_set_size();
        let old_balances = Vector::empty<u64>();
        
        while (i < num_vals){
            let addr = LibraSystem::get_ith_validator_address(i);
            let prev_balance = LibraAccount::balance<GAS::T>(addr);
            Vector::push_back(&mut old_balances, prev_balance);
            i = i + 1;
        };

        TransactionFee::distribute_transaction_fees<GAS::T>();
        
        while (i > 0){
            i = i - 1;
            let prev_balance = Vector::pop_back(&mut old_balances);
            let addr = LibraSystem::get_ith_validator_address(i);
            let new_balance = LibraAccount::balance<GAS::T>(addr);
            Transaction::assert(new_balance > prev_balance, 1);
        };
    }
}