address 0x1 {

module FullnodeState {
  use 0x1::CoreAddresses;
  use 0x1::Signer;
  use 0x1::Vector;

  resource struct FullnodeState { 
      address_vec: vector<address>,
      proofs_vec: vector<u64>,
  }

  public fun initialize(vm: &signer) {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
      move_to<FullnodeState>(
      vm, 
      FullnodeState {
          address_vec: Vector::empty<address>(),
          proofs_vec: Vector::empty<u64>(),
        }
      );
  }


  public fun reset(vm: &signer, height: u64) acquires FullnodeState {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
      let state = borrow_global_mut<FullnodeState>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      state.address_vec = Vector::empty<address>();
      state.proofs_vec = Vector::empty<u64>();
  }

  public fun get_address_proof_count(addr: address):u64 acquires FullnodeState {
      let state = borrow_global<FullnodeState>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      let idx = Vector::index_of<address>(state.address_vec, addr);
      Vector::borrow(state.proofs_vec, idx)
  }
}
}