//! account: alice, 100, 0, validator

//! new-transaction
// Check if genesis subsidies have been distributed
//! sender: libraroot
script {
use 0x1::Subsidy;
use 0x1::LibraAccount;
use 0x1::GAS::GAS;
fun main(vm: &signer) {
    let old_account_bal = LibraAccount::balance<GAS>({{alice}});
    Subsidy::genesis(vm);
    let new_account_bal = LibraAccount::balance<GAS>({{alice}});
    assert(new_account_bal>old_account_bal, 73570001);
    assert(new_account_bal == 225316, 73570002);
}
}
