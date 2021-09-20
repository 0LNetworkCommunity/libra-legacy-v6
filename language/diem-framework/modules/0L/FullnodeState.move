///////////////////////////////////////////////////////////////////////////
// File Prefix for errors: 0600
///////////////////////////////////////////////////////////////////////////

address 0x1 {

/// # Summary
/// This module tracks the activity of the network's fullnodes 
module FullnodeState {
  use 0x1::CoreAddresses;
  use 0x1::Errors;
  use 0x1::Signer;
  use 0x1::Testnet::is_testnet;
  use 0x1::Roles;
  
  struct FullnodeCounter has key {
    proofs_submitted_in_epoch: u64,
    proofs_paid_in_epoch: u64,
    subsidy_in_epoch: u64,
    cumulative_proofs_submitted: u64,
    cumulative_proofs_paid: u64,
    cumulative_subsidy: u64,
  }

  //Function code: 01
  public fun init(sender: &signer) {
      assert(!exists<FullnodeCounter>(Signer::address_of(sender)), Errors::not_published(060001));
      move_to<FullnodeCounter>(
      sender, 
      FullnodeCounter {
          proofs_submitted_in_epoch: 0,
          proofs_paid_in_epoch: 0, // count
          subsidy_in_epoch: 0, // value
          cumulative_proofs_submitted: 0,
          cumulative_proofs_paid: 0,
          cumulative_subsidy: 0,
        }
      );
  }

  // Function code: 2
  /// Called by root at the epoch boundary for each fullnode, updates the cumulative stats and resets the others
  public fun reconfig(vm: &signer, addr: address, proofs_in_epoch: u64) acquires FullnodeCounter {
      Roles::assert_diem_root(vm);
      let state = borrow_global_mut<FullnodeCounter>(addr);
      // update cumulative values
      state.cumulative_proofs_submitted = state.cumulative_proofs_submitted + proofs_in_epoch;
      state.cumulative_proofs_paid = state.cumulative_proofs_paid + state.proofs_paid_in_epoch;
      state.cumulative_subsidy = state.cumulative_subsidy + state.subsidy_in_epoch;
      // reset 
      state.proofs_submitted_in_epoch = proofs_in_epoch;
      state.proofs_paid_in_epoch = 0;
      state.subsidy_in_epoch = 0;
  }

  /// VM Increments payments in epoch for `addr`. Increases by `count`
  // Function code:04
  public fun inc_payment_count(vm: &signer, addr: address, count: u64) acquires FullnodeCounter {
    Roles::assert_diem_root(vm);
    let state = borrow_global_mut<FullnodeCounter>(addr);
    state.proofs_paid_in_epoch = state.proofs_paid_in_epoch + count;
  }

  /// VM Increments subsidy in epoch for `addr`. Increases by `value`
  //Function code:05
  public fun inc_payment_value(vm: &signer, addr: address, value: u64) acquires FullnodeCounter {
    Roles::assert_diem_root(vm);
    let state = borrow_global_mut<FullnodeCounter>(addr);
    state.subsidy_in_epoch = state.subsidy_in_epoch + value;
  }

  /// Function to check whether or not the module has been initialized 
  public fun is_init(addr: address): bool {
    exists<FullnodeCounter>(addr)
  }

  /// Function checks to see if the node is in the process of onboarding 
  /// The first proof is submitted by the node doing the onboarding, so if 
  /// proof submitted < 2, the node hasn't yet produced a proof 
  public fun is_onboarding(addr: address): bool acquires FullnodeCounter{
    let state = borrow_global<FullnodeCounter>(addr);

    state.cumulative_proofs_submitted < 2 &&
    state.cumulative_proofs_paid < 2 &&
    state.cumulative_subsidy < 1000000
  }

  //////// GETTERS /////////

  /// Get the number of proofs submitted in the current epoch for `addr`
  public fun get_address_proof_count(addr:address): u64 acquires FullnodeCounter {
    borrow_global<FullnodeCounter>(addr).proofs_submitted_in_epoch
  }

  /// Get the cumulative subsity for `addr`
  public fun get_cumulative_subsidy(addr: address): u64 acquires FullnodeCounter{
    let state = borrow_global<FullnodeCounter>(addr);
    state.cumulative_subsidy
  }

  //////// TEST HELPERS /////////
  
  // Function code:06
  /// initialize fullnode state for a node and set stats to given values 
  public fun test_set_fullnode_fixtures(
    vm: &signer,
    addr: address,
    proofs_submitted_in_epoch: u64,
    proofs_paid_in_epoch: u64,
    subsidy_in_epoch: u64,
    cumulative_proofs_submitted: u64,
    cumulative_proofs_paid: u64,
    cumulative_subsidy: u64,
  ) acquires FullnodeCounter {
    CoreAddresses::assert_diem_root(vm);
    assert(is_testnet(), Errors::invalid_state(060006));

    let state = borrow_global_mut<FullnodeCounter>(addr);
    state.proofs_submitted_in_epoch = proofs_submitted_in_epoch;
    state.proofs_paid_in_epoch = proofs_paid_in_epoch;
    state.subsidy_in_epoch = subsidy_in_epoch;
    state.cumulative_proofs_submitted = cumulative_proofs_submitted;
    state.cumulative_proofs_paid = cumulative_proofs_paid;
    state.cumulative_subsidy = cumulative_subsidy;
  }

  /// Add `count` proofs to the number submitted by `sender`
  public fun mock_proof(sender: &signer, count: u64) acquires FullnodeCounter {
    assert(is_testnet(), Errors::invalid_state(060006));
    let addr = Signer::address_of(sender);
    let state = borrow_global_mut<FullnodeCounter>(addr);
    state.proofs_submitted_in_epoch = state.proofs_submitted_in_epoch + count;
  }
}
}