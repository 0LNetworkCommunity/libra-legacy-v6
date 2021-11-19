//! account: alice, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: diemroot
script {
  
  use 0x1::Delegation;
  use 0x1::EpochBoundary;

  fun main(vm: signer) {
    // assumes no tx fees were paid
    // Delegation::vm_init(&vm);
    assert(!Delegation::vm_is_init(), 0);
    EpochBoundary::reconfigure(&vm, 0);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
  
  use 0x1::Delegation;
  // use 0x1::EpochBoundary;

  fun main(_vm: signer) {
    // assumes no tx fees were paid
    // Delegation::vm_init(&vm);
    assert(Delegation::vm_is_init(), 0);
    // EpochBoundary::reconfigure(&vm, 0);
  }
}
// check: EXECUTED