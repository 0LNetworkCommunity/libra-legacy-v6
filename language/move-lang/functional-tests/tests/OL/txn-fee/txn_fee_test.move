//! account: bob, 0GAS
//! account: alice, 10GAS

//! new-transaction
// Minting from a privileged account should work
//! sender: association
script {
use 0x0::GAS;
use 0x0::Libra;
use 0x0::LibraAccount;
use 0x0::Transaction;
// use 0x0::TransactionFee;
use 0x0::Debug;

fun main(sender: &signer) {
    // mint a coin the association (tx sender)
    let coin = Libra::mint<GAS::T>(sender, 1000);

    // send coin to Fee collecting address
    LibraAccount::deposit(sender, 0xFEE, coin);
    let amount = LibraAccount::balance<GAS::T>(0xFEE);
    Debug::print(&0x000000000000007E5700000000000001);
    Debug::print(&amount);
    Transaction::assert(Libra::market_cap<GAS::T>() == 1000, 5);
}
}

// check: MintEvent
// check: EXECUTED
