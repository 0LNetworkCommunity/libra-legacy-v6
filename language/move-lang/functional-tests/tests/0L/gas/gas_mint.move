//! account: alice, 1000000, 0, validator

//! new-transaction
//! sender: diemroot
script {
use 0x1::Libra;
use 0x1::GAS::GAS;
use 0x1::LibraAccount;

fun main(vm: &signer) {
    let old_market_cap = Libra::market_cap<GAS>();
    let coin = Libra::mint<GAS>(vm, 1000);
    assert(Libra::value<GAS>(&coin) == 1000, 1);
    assert(Libra::market_cap<GAS>() == old_market_cap + 1000, 2);
    LibraAccount::vm_deposit_with_metadata<GAS>(
        vm,
        {{alice}},
        coin,
        x"", x""
    );
}
}
