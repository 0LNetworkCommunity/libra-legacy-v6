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


// NOTE: Testing the transaction script for creating a new team.

//! new-transaction
//! sender: alice
//! args: b"for the win", 10
stdlib_script::TeamsScripts::create_team
// check: "Keep(EXECUTED)"

//! new-transaction
//! sender: diemroot
script {
  
  
  use 0x1::Teams;

  fun main(_: signer) {
    assert(Teams::team_is_init(@{{alice}}), 735703);
    assert(Teams::get_operator_reward(@{{alice}}) == 10, 735704);

  }
}
// check: EXECUTED
