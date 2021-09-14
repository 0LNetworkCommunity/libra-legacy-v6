//// frank is a fullnode
//! account: frank, 1GAS, 0

//! new-transaction
// Check if genesis subsidies have been distributed
//! sender: diemroot
script {
    use 0x1::Subsidy;
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;

    fun main(vm: signer) {
        let old_account_bal = DiemAccount::balance<GAS>(@{{frank}});
        let value = Subsidy::distribute_fullnode_subsidy(&vm, @{{frank}}, 10);
        let new_account_bal = DiemAccount::balance<GAS>(@{{frank}});

        assert(value == 24975360, 735701);
        assert(new_account_bal == value + 1000000, 735702);
        assert(new_account_bal>old_account_bal, 735703);
    }
}
