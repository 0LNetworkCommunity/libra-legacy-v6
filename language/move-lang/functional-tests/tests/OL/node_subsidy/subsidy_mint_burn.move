//! account: alice, 0GAS
//! account: preburner, 0GAS

//! new-transaction
//! sender: subsidy
script {
use 0x0::Libra;
use 0x0::GAS;
use 0x0::Transaction;
// Make sure that Coin1 and Coin2 are registered
fun main() {
    Transaction::assert(Libra::is_currency<GAS::T>(), 1);
}
}
// check: EXECUTED

//! new-transaction
// Minting from a subsidy account should work
//! sender: subsidy
script {
use 0x0::GAS;
use 0x0::Libra;
use 0x0::LibraAccount;
use 0x0::Transaction;
fun main(account: &signer) {
    // mint 100 coins and check that the market cap increases appropriately
    let old_market_cap = Libra::market_cap<GAS::T>();
    let coin = Libra::mint<GAS::T>(account, 1000);
    Transaction::assert(Libra::value<GAS::T>(&coin) == 1000, 4);
    Transaction::assert(Libra::market_cap<GAS::T>() == old_market_cap + 1000, 5);

    // get rid of the coin
    LibraAccount::deposit(account, {{alice}}, coin);
}
}

// check: MintEvent
// check: EXECUTED
