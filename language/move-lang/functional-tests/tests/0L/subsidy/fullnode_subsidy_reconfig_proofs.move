//! account: alice, 100, 0, validator
//// frank is a fullnode
//! account: frank, 100, 0

//! new-transaction
//! sender: libraroot
script {
    use 0x1::TransactionFee;
    use 0x1::Libra;
    use 0x1::GAS::GAS;
    fun main(vm: &signer) {
        assert(TransactionFee::get_amount_to_distribute(vm)==0, 735701);
        let coin = Libra::mint<GAS>(vm, 1000000);
        TransactionFee::pay_fee(coin);
        assert(TransactionFee::get_amount_to_distribute(vm)==1000000, 735701);

    }
}


//! new-transaction
// Check if genesis subsidies have been distributed
//! sender: libraroot
script {
use 0x1::Subsidy;
use 0x1::LibraAccount;
use 0x1::GAS::GAS;

fun main(vm: &signer) {
    /// No proofs submitted in current epoch. So a single proof is worth the ceiling, i.e. equivalent to tx fees.
    Subsidy::set_global_count(vm, 10000);
    Subsidy::fullnode_reconfig(vm);
    let old_account_bal = LibraAccount::balance<GAS>({{frank}});
    let value = Subsidy::distribute_fullnode_subsidy(vm, {{frank}}, 1,);
    let new_account_bal = LibraAccount::balance<GAS>({{frank}});
    assert(value == 84, 735702);
    assert(new_account_bal>old_account_bal, 73570001);
    assert(new_account_bal == 184, 73570002);
}
}
