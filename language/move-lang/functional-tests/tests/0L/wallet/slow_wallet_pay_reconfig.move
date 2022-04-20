//! account: alice, 30000000GAS,
//! account: bob, 55GAS,
//! account: carol, 22GAS, 0, validator


//! sender: alice
script {
use 0x1::DiemAccount;

fun main(account: signer) {
    // before epoch change, need to mock alice's end-user address as a slow wallet
    DiemAccount::set_slow(&account);
}
}
// check: EXECUTED

// Go through an epoch boundary once to trigger reconfigure

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: carol
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

// This transaction should fail because alice is a slow wallet, and has no GAS unlocked.
//! new-transaction
//! sender: alice
script {
use 0x1::GAS::GAS;
use 0x1::DiemAccount;
use 0x1::Debug::print;

fun main(account: signer) {

    print(&DiemAccount::balance<GAS>(@{{alice}}));
    print(&DiemAccount::unlocked_amount(@{{alice}}));
    print(&DiemAccount::balance<GAS>(@{{bob}}));
    
    assert(DiemAccount::balance<GAS>(@{{alice}}) == 30000000, 735701);
    assert(DiemAccount::unlocked_amount(@{{alice}}) == 10, 735702);
    assert(DiemAccount::balance<GAS>(@{{bob}}) == 55, 735703);

    let with_cap = DiemAccount::extract_withdraw_capability(&account);
    DiemAccount::pay_from<GAS>(&with_cap, @{{bob}}, 5, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);

    assert(DiemAccount::balance<GAS>(@{{bob}}) == 60, 735704);
}
}


// check: EXECUTED