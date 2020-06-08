//! account: bob, 0GAS
//! account: alice, 10GAS

//! new-transaction
// Transfers between accounts is disabled
//! sender: alice
script {
use 0x0::LibraAccount;
use 0x0::GAS;
use 0x0::Transaction;
fun main() {
    LibraAccount::pay_from_sender<GAS::T>({{bob}}, 10);
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 0, 0);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 10, 1);
}
}
// check: ABORTED

//! new-transaction
// Deposit between accounts is disabled
//! sender: alice
script {
use 0x0::LibraAccount;
use 0x0::GAS;
use 0x0::Transaction;
fun main() {
    let coin = LibraAccount::withdraw_from_sender<GAS::T>(10);
    LibraAccount::deposit({{bob}}, coin);
    Transaction::assert(LibraAccount::balance<GAS::T>({{alice}}) == 0, 2);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 10, 3);
}
}
// check: ABORTED

//! new-transaction
// Transfers from association to other accounts is enabled
//! sender: association
script {
use 0x0::Libra;
use 0x0::LibraAccount;
use 0x0::GAS;
use 0x0::Transaction;
fun main() {
    let coin = Libra::mint<GAS::T>(10);
    LibraAccount::deposit({{bob}}, coin);
    Transaction::assert(LibraAccount::balance<GAS::T>({{bob}}) == 10, 4);
}
}
// check: EXECUTED
