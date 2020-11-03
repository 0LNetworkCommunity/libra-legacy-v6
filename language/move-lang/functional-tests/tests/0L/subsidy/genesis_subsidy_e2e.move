//! account: alice, 0GAS, 0, validator
//! account: bob, 0GAS, 0, validator
//! account: carol, 0GAS, 0, validator
//! account: dave, 0GAS, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent


//! new-transaction
// Check if genesis subsidies have been distributed
//! sender: libraroot
script {
use 0x1::LibraAccount;
use 0x1::GAS::GAS;
use 0x1::Debug::print;
fun main(_vm: &signer) {
    print(&{{alice}});
    print(&LibraAccount::balance<GAS>({{alice}}));
    
    assert(LibraAccount::balance<GAS>({{alice}}) == 74, 7357001);
    //assert(LibraAccount::balance<GAS>({{bob}}) == 74, 7357002);
    //assert(LibraAccount::balance<GAS>({{carol}}) == 74, 7357003);
    //assert(LibraAccount::balance<GAS>({{dave}}) == 74, 7357004);

}
}
