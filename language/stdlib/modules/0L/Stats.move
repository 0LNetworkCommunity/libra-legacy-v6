/////////////////////////////////////////////////////////////////////////
// 0L Module
// Stats Module
/////////////////////////////////////////////////////////////////////////

address 0x1{
module Stats{
    use 0x1::Vector;
    use 0x1::CoreAddresses;
    use 0x1::Signer;
    use 0x1::Testnet;
    // use 0x1::Globals;
    use 0x1::FixedPoint32;
    

    struct ValidatorSet {
      addr: vector<address>,
      prop_count: vector<u64>,
      vote_count: vector<u64>,
      total_votes: u64,
      total_props: u64,
    }

    resource struct T {
      history: vector<ValidatorSet>,
      current: ValidatorSet
    }

    //Permissions: Public, VM only.
    public fun initialize(vm: &signer) {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190201014010);
       move_to<T>(
        vm, 
        T {
            history: Vector::empty(),
            current: blank()
          }
        );
    }
    
  fun blank():ValidatorSet {
    ValidatorSet {
        addr: Vector::empty(),
        prop_count: Vector::empty(),
        vote_count: Vector::empty(),
        total_votes: 0,
        total_props: 0,
      }
  }

    //Permissions: Public, VM only.
    public fun init_address(vm: &signer, node_addr: address) acquires T {
      let sender = Signer::address_of(vm);

      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 190204014010);

      let stats = borrow_global_mut<T>(sender);
      let (is_init, _) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      if (!is_init) {
        Vector::push_back(&mut stats.current.addr, node_addr);
        Vector::push_back(&mut stats.current.prop_count, 0);
        Vector::push_back(&mut stats.current.vote_count, 0);
      }
    }

    public fun init_set(vm: &signer, set: &vector<address>) acquires T{
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190205014010);
      let length = Vector::length<address>(set);
      let k = 0;
      while (k < length) {
        let node_address = *(Vector::borrow<address>(set, k));
        init_address(vm, node_address);
        k = k + 1;
      }
    }

    public fun process_set_votes(vm: &signer, set: &vector<address>) acquires T{
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190206014010);

      let length = Vector::length<address>(set);
      let k = 0;
      while (k < length) {
        let node_address = *(Vector::borrow<address>(set, k));
        inc_vote(vm, node_address);
        k = k + 1;
      }
    }

    //Permissions: Public, VM only.
    public fun node_current_votes(vm: &signer, node_addr: address): u64 acquires T {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190202014010);
      let stats = borrow_global_mut<T>(sender);
      let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      *Vector::borrow<u64>(&mut stats.current.vote_count, i)
    }

    public fun node_above_thresh(vm: &signer, node_addr: address, height_start: u64, height_end: u64): bool acquires T{
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190206014010);
      let range = height_end-height_start;
      let threshold_signing = FixedPoint32::multiply_u64(range, FixedPoint32::create_from_rational(33, 100));
      if (node_current_votes(vm, node_addr) >  threshold_signing) { return true };
      return false
    }

    // public fun get_nodes_(node_addr: address): bool acquires T{
    //   Transaction::assert(Transaction::sender() == 0x0, 99190202014010);
    //   let range = Globals::get_epoch_length();
    //   let threshold_signing = FixedPoint32::multiply_u64(range, FixedPoint32::create_from_rational(66, 100));
    //   if (node_current_votes(node_addr) >  threshold_signing) return true;
    //   return false
    // }


    public fun network_density(vm: &signer, height_start: u64, height_end: u64): u64 acquires T {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190206014010);
      let density = 0u64;
      let nodes = *&(borrow_global_mut<T>(sender).current.addr);
      let len = Vector::length(&nodes);
      let k = 0;
      while (k < len) {
        let addr = *(Vector::borrow<address>(&nodes, k));
        if (node_above_thresh(vm, addr, height_start, height_end)) {
          density = density + 1;
        };
        k = k + 1;
      };
      return density
    }

    //Permissions: Public, VM only.
    public fun node_current_props(vm: &signer, node_addr: address): u64 acquires T {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190206014010);
      let stats = borrow_global_mut<T>(sender);
      let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      *Vector::borrow<u64>(&mut stats.current.prop_count, i)
    }

    //Permissions: Public, VM only.
    public fun inc_prop(vm: &signer, node_addr: address) acquires T {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190205014010);

      let stats = borrow_global_mut<T>(sender);
      let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      let test = *Vector::borrow<u64>(&mut stats.current.prop_count, i);
      Vector::push_back(&mut stats.current.prop_count, test + 1);
      Vector::swap_remove(&mut stats.current.prop_count, i);
      // stats.current.total_props = stats.current.total_props + 1;

    }
    
    //TODO: Duplicate code.
    //Permissions: Public, VM only.
    fun inc_vote(vm: &signer, node_addr: address) acquires T {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190206014010);
      let stats = borrow_global_mut<T>(sender);
      let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      let test = *Vector::borrow<u64>(&mut stats.current.vote_count, i);
      Vector::push_back(&mut stats.current.vote_count, test + 1);
      Vector::swap_remove(&mut stats.current.vote_count, i);
      stats.current.total_votes = stats.current.total_votes + 1;
    }

    //Permissions: Public, VM only.
    public fun reconfig(vm: &signer, set: &vector<address>) acquires T {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190207014010);
      let stats = borrow_global_mut<T>(sender);
      // Archive outgoing epoch stats.
      //TODO: limit the size of the history and drop ancient records.
      Vector::push_back(&mut stats.history, *&stats.current);

      stats.current = blank();
      
      init_set(vm, set);
    }

    public fun get_total_votes(vm: &signer): u64 acquires T {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190208014010);
      *&borrow_global_mut<T>(CoreAddresses::LIBRA_ROOT_ADDRESS()).current.total_votes
    }

    public fun get_history(): vector<ValidatorSet> acquires T {
      *&borrow_global_mut<T>(CoreAddresses::LIBRA_ROOT_ADDRESS()).history
    }

    /// TEST HELPERS

    public fun test_helper_inc_vote_addr(vm: &signer, node_addr: address) acquires T {
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 99190209014010);

      assert(Testnet::is_testnet(), 99190210014010);
      inc_vote(vm, node_addr);
    }

}
}