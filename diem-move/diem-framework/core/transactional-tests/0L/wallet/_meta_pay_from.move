//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,


// META: transfers between bob and carol (not slow wallets) works fine
//! new-transaction
//! sender: carol
script {
use DiemFramework::GAS::GAS;
use DiemFramework::DiemAccount;

fun main(account: signer) {
    assert!(DiemAccount::balance<GAS>(@Bob) == 10, 735701);

    let with_cap = DiemAccount::extract_withdraw_capability(&account);
    DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);
    assert!(DiemAccount::balance<GAS>(@Bob) == 20, 735701);
}
}


// check: EXECUTED