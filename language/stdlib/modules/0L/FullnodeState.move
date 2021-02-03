address 0x1 {

module FullnodeState {
  use 0x1::CoreAddresses;
  use 0x1::Signer;
  // use 0x1::MinerState;

  resource struct FullnodeCounter {
    proofs_submitted_in_epoch: u64,
    proofs_paid_in_epoch: u64,
    subsidy_in_epoch: u64,
    cumulative_proofs_submitted: u64,
    cumulative_proofs_paid: u64,
    cumulative_subsidy: u64,
  }

  public fun init(sender: &signer) {
      assert(!exists<FullnodeCounter>(Signer::address_of(sender)), 130112011021);
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

  /// On recongfiguration events, reset.
  public fun reconfig(vm: &signer, addr: address, proofs_in_epoch: u64) acquires FullnodeCounter {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
      let state = borrow_global_mut<FullnodeCounter>(addr);
      state.cumulative_proofs_submitted = state.cumulative_proofs_submitted + proofs_in_epoch;
      state.cumulative_proofs_paid = state.cumulative_proofs_paid + state.proofs_paid_in_epoch;
      state.cumulative_subsidy = state.cumulative_subsidy + state.subsidy_in_epoch;
      // reset 
      state.proofs_submitted_in_epoch= proofs_in_epoch;
      state.proofs_paid_in_epoch = 0;
      state.subsidy_in_epoch = 0;
  }

  /// Miner increments proofs by 1
  /// TO
  // public fun inc_proof(sender: &signer) acquires FullnodeCounter {
  //   let addr = Signer::address_of(sender);
  //     let state = borrow_global_mut<FullnodeCounter>(addr);
  //     state.proofs_submitted_in_epoch = state.proofs_submitted_in_epoch + 1;
  // }

  /// VM Increments payments in epoch. Increases by `count`
  public fun inc_payment_count(vm: &signer, addr: address, count: u64) acquires FullnodeCounter {
    assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
    let state = borrow_global_mut<FullnodeCounter>(addr);
    state.proofs_paid_in_epoch = state.proofs_paid_in_epoch + count;
  }

    /// VM Increments payments in epoch. Increases by `count`
  public fun inc_payment_value(vm: &signer, addr: address, value: u64) acquires FullnodeCounter {
    assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
    let state = borrow_global_mut<FullnodeCounter>(addr);
    state.subsidy_in_epoch = state.subsidy_in_epoch + value;
  }
}
}