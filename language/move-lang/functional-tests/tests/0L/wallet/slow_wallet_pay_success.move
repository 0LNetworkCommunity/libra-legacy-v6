//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,


//! new-transaction
//! sender: diemroot
script {
use 0x1::DiemAccount;
fun main(vm: signer) {
    DiemAccount::slow_wallet_epoch_drip(&vm, 100);
    assert(DiemAccount::unlocked_amount(@{{alice}}) == 100, 735701);

}
}


// check: EXECUTED

// Successful unlock and transfer.

//! new-transaction
//! sender: alice
script {
use 0x1::GAS::GAS;
use 0x1::DiemAccount;

fun main(account: signer) {
    assert(DiemAccount::balance<GAS>(@{{bob}}) == 10, 735702);

    let with_cap = DiemAccount::extract_withdraw_capability(&account);
    DiemAccount::pay_from<GAS>(&with_cap, @{{bob}}, 10, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);

    assert(DiemAccount::balance<GAS>(@{{bob}}) == 20, 735703);
}
}


// check: EXECUTED