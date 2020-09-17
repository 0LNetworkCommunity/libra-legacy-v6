//! account: alice, 0GAS
//! new-transaction
//! sender: blessed

script {
use 0x1::Libra;
use 0x1::GAS::GAS;
use 0x1::LibraAccount;
// use 0x1::Debug;
fun main(account: &signer) {
    let old_market_cap = Libra::market_cap<GAS>();
    let coin = Libra::mint<GAS>(account, 1000);
    assert(Libra::value<GAS>(&coin) == 1000, 1);
    assert(Libra::market_cap<GAS>() == old_market_cap + 1000, 2);
    LibraAccount::deposit_gas(account, {{alice}}, coin);
    
}
}
// check: ReceivedPaymentEvent
// check: "Keep(EXECUTED)"