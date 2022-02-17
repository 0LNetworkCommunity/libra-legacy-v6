//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0
//! account: eve, 1000000, 0
//! account: dave, 1000000, 0, validator

// NOTE: alice is validator, she will become a tribal elder.
// then Bob will join her tribe.


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: diemroot
script {
  
  use 0x1::Teams;
  use 0x1::EpochBoundary;

  fun main(vm: signer) {
    // nothing is initialized yet
    assert(!Teams::vm_is_init(), 735701);
    assert(!Teams::team_is_init(@{{alice}}), 735702);
    EpochBoundary::reconfigure(&vm, 0);
  }
}
// check: EXECUTED
