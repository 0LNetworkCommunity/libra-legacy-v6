address 0x1 {

module FullnodeState {
  use 0x1::CoreAddresses;
  use 0x1::Signer;

  resource struct FullnodeCounter {
    proofs_submitted_in_epoch: u64,
    proofs_paid_in_epoch: u64,
    cumulative_proofs_submitted: u64,
    cumulative_proofs_paid: u64,
  }

  public fun initialize(sender: &signer) {
      assert(!exists<FullnodeCounter>(Signer::address_of(sender)), 130112011021);
      move_to<FullnodeCounter>(
      sender, 
      FullnodeCounter {
          proofs_submitted_in_epoch: 0,
          proofs_paid_in_epoch: 0,
          cumulative_proofs_submitted: 0,
          cumulative_proofs_paid: 0,
        }
      );
  }

  public fun reset(vm: &signer, addr: address) acquires FullnodeCounter {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
      let state = borrow_global_mut<FullnodeCounter>(addr);
      state.cumulative_proofs_submitted = state.cumulative_proofs_submitted + state.proofs_submitted_in_epoch;
      state.cumulative_proofs_paid = state.cumulative_proofs_paid + state.proofs_paid_in_epoch;
      // reset 
      state.proofs_submitted_in_epoch= 0;
      state.proofs_paid_in_epoch = 0;
  }

  public fun inc_proof(sender: &signer) acquires FullnodeCounter {
    let addr = Signer::address_of(sender);
    let state = borrow_global_mut<FullnodeCounter>(addr);
    state.proofs_paid_in_epoch = state.proofs_paid_in_epoch + 1;
  }

  public fun inc_payment(sender: &signer) acquires FullnodeCounter {
    let addr = Signer::address_of(sender);
    let state = borrow_global_mut<FullnodeCounter>(addr);
    state.proofs_submitted_in_epoch = state.proofs_submitted_in_epoch + 1;
  }

  public fun get_address_proof_count(addr: address):u64 acquires FullnodeCounter {
    let state = borrow_global<FullnodeCounter>(addr);
    state.proofs_submitted_in_epoch
  }
}
}