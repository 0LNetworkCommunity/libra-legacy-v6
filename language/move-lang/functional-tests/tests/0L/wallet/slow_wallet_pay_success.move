//! account: alice, 1000000GAS, 0, validator
//! account: bob, 10GAS,
//! account: carol, 10GAS,


//! new-transaction
//! sender: diemroot
script {
use 0x1::DiemAccount;
fun main(vm: signer) {
    DiemAccount::increment_all(&vm, 100);
}
}


// check: EXECUTED

// This transaction should fail because alice is a slow wallet, and has no GAS unlocked.
//! new-transaction
//! sender: alice
script {
use 0x1::GAS::GAS;
use 0x1::DiemAccount;
use 0x1::Debug::print;
fun main(account: signer) {

    let with_cap = DiemAccount::extract_withdraw_capability(&account);
    DiemAccount::pay_from<GAS>(&with_cap, @{{bob}}, 10, x"", x"");
    DiemAccount::restore_withdraw_capability(with_cap);
    print(&DiemAccount::balance<GAS>(@{{bob}}));
    // assert(DiemAccount::balance<GAS>(@{{bob}}) == 10, 735701);
    // assert(DiemAccount::sequence_number(addr) == 0, 84);
}
}


// check: EXECUTED