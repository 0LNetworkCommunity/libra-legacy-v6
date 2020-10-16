script {
    use 0x1::GAS::GAS;
    // use 0x1::Libra;
    use 0x1::LibraAccount;
    use 0x1::LibraSystem;
    use 0x1::Vector;

    fun ol_txn_fee_test_distr(account: &signer) {
        let i = 0;
        let num_vals = LibraSystem::validator_set_size();
        let old_balances = Vector::empty<u64>();
        
        while (i < num_vals){
            let addr = LibraSystem::get_ith_validator_address(i);
            let prev_balance = LibraAccount::balance<GAS>(addr);
            Vector::push_back(&mut old_balances, prev_balance);
            i = i + 1;
        };

        LibraSystem::distribute_transaction_fees(account);
        
        while (i > 0){
            i = i - 1;
            let prev_balance = Vector::pop_back(&mut old_balances);
            let addr = LibraSystem::get_ith_validator_address(i);
            let new_balance = LibraAccount::balance<GAS>(addr);
            assert(new_balance > prev_balance, 1);
        };
    }
}