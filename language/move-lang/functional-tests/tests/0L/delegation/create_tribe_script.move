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
    // nothing is initialized yet
    assert(!Delegation::vm_is_init(), 735701);
    assert(!Delegation::elder_is_init(@{{alice}}), 735702);
    EpochBoundary::reconfigure(&vm, 0);
  }
}
// check: EXECUTED


// NOTE: Testing the transaction script for creating a new tribe.

//! new-transaction
//! sender: alice
//! args: b"apes_and_frogs", 10
stdlib_script::DelegationScripts::create_tribe
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: diemroot
script {
  
  use 0x1::Delegation;

  fun main(_: signer) {
    assert(Delegation::elder_is_init(@{{alice}}), 735703);
    assert(Delegation::get_operator_bonus(@{{alice}}) == 10, 735704);

  }
}
// check: EXECUTED
