//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

//! account: alice, 0GAS
//! account: preburner, 0GAS

//! new-transaction
//! sender: association
script {
use 0x0::Libra;
use 0x0::GAS;
use 0x0::Transaction;
fun main() {
    Transaction::assert(Libra::approx_lbr_for_value<GAS::T>(10) == 10, 1);
    Transaction::assert(Libra::scaling_factor<GAS::T>() == 1000000, 2);
    Transaction::assert(Libra::fractional_part<GAS::T>() == 1000, 3);
}
}

// check: EXECUTED

//! new-transaction
// Minting from a privileged account should work
//! sender: association
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
