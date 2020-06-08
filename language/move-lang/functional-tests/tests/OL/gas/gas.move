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
fun main() {
    // mint 100 coins and check that the market cap increases appropriately
    let old_market_cap = Libra::market_cap<GAS::T>();
    let coin = Libra::mint<GAS::T>(100);
    Transaction::assert(Libra::value<GAS::T>(&coin) == 100, 4);
    Transaction::assert(Libra::market_cap<GAS::T>() == old_market_cap + 100, 5);

    // get rid of the coin
    LibraAccount::deposit({{alice}}, coin);
}
}

// check: MintEvent
// check: EXECUTED

//! new-transaction
// Minting from a non-privileged account should not work
script {
use 0x0::GAS;
use 0x0::Libra;
use 0x0::LibraAccount;
fun main() {
    let coin = Libra::mint<GAS::T>(100);
    LibraAccount::deposit_to_sender<GAS::T>(coin);
}
}

// will fail with MISSING_DATA because sender doesn't have the mint capability
// check: Keep
// check: MISSING_DATA

//! new-transaction
// create 100 GAS's for the preburner. we can't do this using the //! account macro because it
// doesn't increment the market cap appropriately
//! sender: association
//! max-gas: 1000000
//! gas-price: 0
script {
use 0x0::GAS;
use 0x0::Libra;
use 0x0::LibraAccount;
use 0x0::Transaction;
fun main() {
    let coin = Libra::mint<GAS::T>(100);
    LibraAccount::deposit({{preburner}}, coin);
    Transaction::assert(LibraAccount::balance<GAS::T>({{preburner}}) == 100, 6);
}
}

// check: MintEvent
// check: EXECUTED

// register the sender as a preburn entity
//! new-transaction
//! sender: preburner
//! max-gas: 1000000
//! gas-price: 0
script {
use 0x0::GAS;
use 0x0::Libra;
fun main() {
    Libra::publish_preburn(Libra::new_preburn<GAS::T>())
}
}

// check: EXECUTED

// perform a preburn
//! new-transaction
//! sender: preburner
//! max-gas: 1000000
//! gas-price: 0
script {
use 0x0::GAS;
use 0x0::Libra;
use 0x0::LibraAccount;
use 0x0::Transaction;
fun main() {
    let coin = LibraAccount::withdraw_from_sender<GAS::T>(100);
    let old_market_cap = Libra::market_cap<GAS::T>();
    // send the coins to the preburn bucket. market cap should not be affected, but the preburn
    // bucket should increase in size by 100
    Libra::preburn_to_sender<GAS::T>(coin);
    Transaction::assert(Libra::market_cap<GAS::T>() == old_market_cap, 8002);
    Transaction::assert(Libra::preburn_value<GAS::T>() == 100, 8003);
}
}

// check: PreburnEvent
// check: EXECUTED

// perform the burn from the Association account
//! new-transaction
//! sender: association
//! max-gas: 1000000
//! gas-price: 0
script {
use 0x0::GAS;
use 0x0::Libra;
use 0x0::Transaction;
fun main() {
    let old_market_cap = Libra::market_cap<GAS::T>();
    // do the burn. the market cap should now decrease, and the preburn bucket should be empty
    Libra::burn<GAS::T>({{preburner}});
    Transaction::assert(Libra::market_cap<GAS::T>() == old_market_cap - 100, 8004);
    Transaction::assert(Libra::preburn_value<GAS::T>() == 0, 8005);
}
}

// check: BurnEvent
// check: EXECUTED