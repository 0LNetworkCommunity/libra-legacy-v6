//! account: alice, 1000000, 0, validator

// NOTE: delegation is not yet initialized by vm.
// transaction should not cause the state machine to halt.
// test all public functions of delegation here.

//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: alice
script {
  
  use 0x1::Delegation;

  fun main(alice: signer) {
    Delegation::elder_init(&alice, b"tribe name", 50); // 50% fee
  }
}
// check: EXECUTED


//! new-transaction
//! sender: alice
script {
  
  use 0x1::Delegation;
  use 0x1::Signer;

  fun main(alice: signer) {
    let addr = Signer::address_of(&alice);
    let a = Delegation::get_operator_bonus(addr); // 50% fee
    assert(a == 0, 735701)
  }
}
// check: EXECUTED


