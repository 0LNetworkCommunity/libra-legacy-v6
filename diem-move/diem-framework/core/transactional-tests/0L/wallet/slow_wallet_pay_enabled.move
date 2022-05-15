//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,


//# run --admin-script --signers DiemRoot DiemRoot
script {
use DiemFramework::DiemAccount;
use DiemFramework::DiemConfig;
use DiemFramework::Testnet;
use DiemFramework::EpochBoundary;
fun main(vm: signer) {
    // transfers are always enabled on testnet, unsetting testnet would make transfers not work, unless the conditions are met.
    Testnet::remove_testnet(&vm);
    assert!(!DiemConfig::check_transfer_enabled(), 735701);
    assert!(DiemAccount::unlocked_amount(@Alice) == 0, 735702);

    // TODO: simulate epoch boundary with testsuite directives. Annoying to do with production values. Note: after an epoch change event subsequent transactions appear expired after long epochs in tests. Using reconfigure() for now.

    EpochBoundary::reconfigure(&vm, 30);
}
}

//! new-transaction
//! sender: alice

script {
use DiemFramework::GAS::GAS;
use DiemFramework::DiemAccount;
fun main() {
    assert!(DiemAccount::unlocked_amount(@Alice) == 0, 735703);
    assert!(DiemAccount::balance<GAS>(@Bob) == 10, 735704);
}
}

// check: EXECUTED

// Alice tries to send the payment anyways.

//! new-transaction
//! sender: alice
script {
use DiemFramework::GAS::GAS;
use DiemFramework::DiemAccount;
fun main(account: signer) {

    let with_cap = DiemAccount::extract_withdraw_capability(&account);
    DiemAccount::pay_from<GAS>(&with_cap, @Bob, 5, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);
}
}


// check: ABORTED