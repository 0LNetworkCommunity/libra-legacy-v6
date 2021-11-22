//! account: alice, 1000000, 0, validator

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


// now that the vm has been initialized for delegation. Initialize a team.

//! new-transaction
//! sender: alice
script {
  
  use 0x1::Teams;

  fun main(alice: signer) {
    // nothing is initialized yet

    let team_name = b"for the win";
    Teams::team_init(&alice, team_name, 10); // 10% operator bonus.

    assert(Teams::team_is_init(@{{alice}}), 735703);
    assert(Teams::get_operator_reward(@{{alice}}) == 10, 735704);

    
  }
}
// check: EXECUTED
