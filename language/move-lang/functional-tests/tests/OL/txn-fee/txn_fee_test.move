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

fun main(account: &signer) {
    // mint 100 coins and check that the market cap increases appropriately
    let coin = Libra::mint<GAS::T>(account, 1000);

    // get rid of the coin
    LibraAccount::deposit(account, 0xFEE, coin);
    let amount = LibraAccount::balance<GAS::T>(0xFEE);
    Debug::print(&0x000000000000007E5700000000000001);
    Debug::print(&amount);
    Transaction::assert(Libra::market_cap<GAS::T>() == 1000, 5);
}
}

// check: MintEvent
// check: EXECUTED
