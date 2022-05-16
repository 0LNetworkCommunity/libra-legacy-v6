//! account: alice, 1000000GAS, 0, validator

// Check if genesis subsidies have been distributed

//# run --admin-script --signers DiemRoot DiemRoot
script {
use DiemFramework::Subsidy;
use DiemFramework::DiemAccount;
use DiemFramework::GAS::GAS;

fun main(vm: signer, _: signer) {
    let old_account_bal = DiemAccount::balance<GAS>(@Alice);
    // Test suite starts with a minimum of 1 GAS.
    Subsidy::genesis(&vm);
    let new_account_bal = DiemAccount::balance<GAS>(@Alice);
    assert!(new_account_bal > old_account_bal, 73570001);
    // two coins are added at genesis, one for validator and a second which will go to operator.
    assert!(new_account_bal == 12000000, 73570002);
}
}
