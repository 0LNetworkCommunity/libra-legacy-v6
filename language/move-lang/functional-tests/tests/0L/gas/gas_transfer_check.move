//! account: alice, 100, 0, validator
//! account: bob, 100, 0

//! new-transaction
// Transfers between accounts is disabled
//! sender: alice
//! gas-currency: GAS
script {
use 0x1::LibraAccount;
use 0x1::GAS::GAS;
use 0x1::Testnet;
fun main(account: &signer) {
    //transfers are enabled in testnet, need to disable testnet to check that they are disabled otherwise
    Testnet::remove_testnet(account);
    let with_cap = LibraAccount::extract_withdraw_capability(account);
    LibraAccount::pay_from<GAS>(&with_cap, {{bob}}, 10, x"", x"");
    assert(LibraAccount::balance<GAS>({{alice}}) == 0, 0);
    assert(LibraAccount::balance<GAS>({{bob}}) == 10, 1);
    LibraAccount::restore_withdraw_capability(with_cap);
}
}
////////// Transfers should fail ////////
// check: VMExecutionFailure
/////////////////////////////////////////

// //! new-transaction
// // Transfers from libraroot to other accounts is enabled
// //! sender: libraroot
// //! gas-currency: GAS
// script {
// use 0x1::Libra;
// use 0x1::LibraAccount;
// use 0x1::GAS;
// ;
// fun main(account: &signer) {
//     let coin = Libra::mint<GAS::T>(account, 10);
//     LibraAccount::deposit(account, {{bob}}, coin);
//     assert(LibraAccount::balance<GAS>({{bob}}) == 10, 4);
// }
// }
// // check: EXECUTED
