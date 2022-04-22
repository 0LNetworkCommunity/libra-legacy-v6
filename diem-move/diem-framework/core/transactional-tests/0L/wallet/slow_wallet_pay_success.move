//# init --validators Alice
//! account: bob, 10GAS,
//! account: carol, 10GAS,


//! new-transaction
//! sender: diemroot
script {
use DiemFramework::DiemAccount;
fun main(vm: signer) {
    DiemAccount::slow_wallet_epoch_drip(&vm, 100);
    assert!(DiemAccount::unlocked_amount(@Alice) == 100, 735701);

}
}


// check: EXECUTED

// Successful unlock and transfer.

//! new-transaction
//! sender: alice
script {
use DiemFramework::GAS::GAS;
use DiemFramework::DiemAccount;

fun main(account: signer) {
    assert!(DiemAccount::balance<GAS>(@Bob) == 10, 735702);

    let with_cap = DiemAccount::extract_withdraw_capability(&account);
    DiemAccount::pay_from<GAS>(&with_cap, @Bob, 10, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);

    assert!(DiemAccount::balance<GAS>(@Bob) == 20, 735703);
}
}


// check: EXECUTED