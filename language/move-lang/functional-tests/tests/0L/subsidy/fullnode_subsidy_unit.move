//// frank is a fullnode
//! account: frank, 100, 0

//! new-transaction
// Check if genesis subsidies have been distributed
//! sender: libraroot
script {
use 0x1::Subsidy;
use 0x1::LibraAccount;
use 0x1::GAS::GAS;
use 0x1::Debug::print;
fun main(vm: &signer) {
    let old_account_bal = LibraAccount::balance<GAS>({{frank}});
    let value = Subsidy::distribute_fullnode_subsidy(vm, {{frank}}, 10, false);
    let new_account_bal = LibraAccount::balance<GAS>({{frank}});
    print(&value);
    assert(value == 6756480, 735701);
    assert(new_account_bal == 6756580, 735702);

    print(&new_account_bal);
    assert(new_account_bal>old_account_bal, 735703);
}
}
