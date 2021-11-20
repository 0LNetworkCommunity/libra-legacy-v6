//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0

// NOTE: alice is validator, she will become a tribal elder.
// then Bob will join her tribe.


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


// now that the vm has been initialized for delegation. Initialize an elder.

//! new-transaction
//! sender: alice
script {
  
  use 0x1::Delegation;

  fun main(alice: signer) {
    // nothing is initialized yet

    let tribe_name = b"apes_and_frogs";
    Delegation::elder_init(&alice, tribe_name, 10); // 10% operator bonus.

    assert(Delegation::elder_is_init(@{{alice}}), 735703);
    assert(Delegation::get_operator_bonus(@{{alice}}) == 10, 735704);

    
  }
}
// check: EXECUTED


//! new-transaction
//! sender: bob
script {
  
  use 0x1::Delegation;

  fun main(bob: signer) {
    // nothing is initialized yet

    Delegation::join(&alice); // alice's account is the ID of the tribe 
  }
}
// check: EXECUTED