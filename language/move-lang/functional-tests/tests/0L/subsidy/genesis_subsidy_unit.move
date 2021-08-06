//! account: alice, 1GAS, 0, validator

// Check if genesis subsidies have been distributed

//! new-transaction
//! sender: diemroot
script {
use 0x1::Subsidy;
use 0x1::DiemAccount;
use 0x1::GAS::GAS;

fun main(vm: signer) {
    let old_account_bal = DiemAccount::balance<GAS>({{alice}});
    // Test suite starts with a minimum of 1 GAS.
    Subsidy::genesis(&vm);
    let new_account_bal = DiemAccount::balance<GAS>({{alice}});
    assert(new_account_bal>old_account_bal, 73570001);
    assert(new_account_bal == 3497536, 73570002);
}
}
