//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,

// Go through an epoch boundary once to trigger reconfigure

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

// This transaction should fail because alice is a slow wallet, and has no GAS unlocked.
//! new-transaction
//! sender: alice
script {
use DiemFramework::GAS::GAS;
use DiemFramework::DiemAccount;
fun main(account: signer) {
    assert!(DiemAccount::unlocked_amount(@Alice) == 10, 735701);
    assert!(DiemAccount::balance<GAS>(@Bob) == 10, 735701);

    let with_cap = DiemAccount::extract_withdraw_capability(&account);
    DiemAccount::pay_from<GAS>(&with_cap, @Bob, 5, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);
    assert!(DiemAccount::balance<GAS>(@Bob) == 15, 735701);
}
}


// check: EXECUTED