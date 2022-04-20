//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,


//! new-transaction
//! sender: diemroot
script {
use 0x1::DiemAccount;
// use 0x1::DiemConfig;
use 0x1::Testnet;
use 0x1::EpochBoundary;
fun main(vm: signer) {
    // transfers are always enabled on testnet, unsetting testnet would make transfers not work, unless the conditions are met.
    Testnet::remove_testnet(&vm);
    // assert(!DiemConfig::check_transfer_enabled(), 735701);
    assert(DiemAccount::unlocked_amount(@{{alice}}) == 0, 735702);

    // TODO: simulate epoch boundary with testsuite directives. Annoying to do with production values. Note: after an epoch change event subsequent transactions appear expired after long epochs in tests. Using reconfigure() for now.

    EpochBoundary::reconfigure(&vm, 30);
}
}

//! new-transaction
//! sender: alice

script {
use 0x1::GAS::GAS;
use 0x1::DiemAccount;
use 0x1::Debug::print;
fun main(_account: signer) {
    print(&777);
    print(&DiemAccount::unlocked_amount(@{{alice}}));
    assert(DiemAccount::unlocked_amount(@{{alice}}) == 1000000000, 735703);
    assert(DiemAccount::balance<GAS>(@{{bob}}) == 10, 735704);
}
}

// check: EXECUTED

// Alice tries to send the payment anyways.

//! new-transaction
//! sender: alice
script {
use 0x1::GAS::GAS;
use 0x1::DiemAccount;
fun main(account: signer) {

    let with_cap = DiemAccount::extract_withdraw_capability(&account);
    DiemAccount::pay_from<GAS>(&with_cap, @{{bob}}, 5, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);
}
}


// check: EXECUTED