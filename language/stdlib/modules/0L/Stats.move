/////////////////////////////////////////////////////////////////////////
// 0L Module
// Demo Persistence
/////////////////////////////////////////////////////////////////////////

address 0x0{
module Stats{
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::Signer;
    use 0x0::Globals;
    use 0x0::FixedPoint32;
    use 0x0::Testnet;

    // use 0x0::Debug::print;

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
    public fun initialize(vm: &signer){
      Transaction::assert(Signer::address_of(vm) == 0x0, 99190201014010);
      move_to_sender<T>( T {
        history: Vector::empty(),
        current: blank()
      })
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
    public fun init_address(node_addr: address) acquires T {
      Transaction::assert(Transaction::sender() == 0x0, 99190204014010);
      let stats = borrow_global_mut<T>(Transaction::sender());
      Vector::push_back(&mut stats.current.addr, node_addr);
      Vector::push_back(&mut stats.current.prop_count, 0);
      Vector::push_back(&mut stats.current.vote_count, 0);
    }


    public fun init_set(set: &vector<address>) acquires T{
      Transaction::assert(Transaction::sender() == 0x0, 99190205014010);
      let length = Vector::length<address>(set);
      let k = 0;
      while (k < length) {
        let node_address = *(Vector::borrow<address>(set, k));
        init_address(node_address);
        k = k + 1;
      }
    }

    public fun process_set_votes(set: &vector<address>) acquires T{
      Transaction::assert(Transaction::sender() == 0x0, 99190206014010);
      let length = Vector::length<address>(set);
      let k = 0;
      while (k < length) {
        let node_address = *(Vector::borrow<address>(set, k));
        inc_vote(node_address);
        k = k + 1;
      }
    }

    //Permissions: Public, VM only.
    public fun node_current_votes(node_addr: address): u64 acquires T {
      Transaction::assert(Transaction::sender() == 0x0, 99190202014010);
      let stats = borrow_global_mut<T>(Transaction::sender());
      let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      *Vector::borrow<u64>(&mut stats.current.vote_count, i)
    }

    public fun node_above_thresh(node_addr: address): bool acquires T{
      Transaction::assert(Transaction::sender() == 0x0, 99190202014010);
      let range = Globals::get_epoch_length();
      let threshold_signing = FixedPoint32::multiply_u64(range, FixedPoint32::create_from_rational(66, 100));
      if (node_current_votes(node_addr) >  threshold_signing) return true;
      return false
    }

    // public fun get_nodes_(node_addr: address): bool acquires T{
    //   Transaction::assert(Transaction::sender() == 0x0, 99190202014010);
    //   let range = Globals::get_epoch_length();
    //   let threshold_signing = FixedPoint32::multiply_u64(range, FixedPoint32::create_from_rational(66, 100));
    //   if (node_current_votes(node_addr) >  threshold_signing) return true;
    //   return false
    // }


    public fun network_density (): u64 acquires T {
      Transaction::assert(Transaction::sender() == 0x0, 99190202014010);
      let density = 0u64;
      let nodes = *&(borrow_global_mut<T>(Transaction::sender()).current.addr);
      let length = Vector::length(&nodes);
      let k = 0;
      while (k < length) {
        let addr = *(Vector::borrow<address>(&nodes, k));
        if (node_above_thresh(addr)) {
          density = density + 1;
        };
        k = k + 1;
      };
      return density
    }

    //Permissions: Public, VM only.
    public fun node_current_props(node_addr: address): u64 acquires T {
      Transaction::assert(Transaction::sender() == 0x0, 99190203014010);
      let stats = borrow_global_mut<T>(Transaction::sender());
      let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      *Vector::borrow<u64>(&mut stats.current.prop_count, i)
    }

    //Permissions: Public, VM only.
    public fun inc_prop(node_addr: address) acquires T {
      Transaction::assert(Transaction::sender() == 0x0, 99190205014010);
      let stats = borrow_global_mut<T>(Transaction::sender());
      let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      let test = *Vector::borrow<u64>(&mut stats.current.prop_count, i);
      Vector::push_back(&mut stats.current.prop_count, test + 1);
      Vector::swap_remove(&mut stats.current.prop_count, i);
      // stats.current.total_props = stats.current.total_props + 1;

    }
    
    //TODO: Duplicate code.
    //Permissions: Public, VM only.
    fun inc_vote(node_addr: address) acquires T {
      Transaction::assert(Transaction::sender() == 0x0, 99190206014010);
      let stats = borrow_global_mut<T>(Transaction::sender());
      let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
      let test = *Vector::borrow<u64>(&mut stats.current.vote_count, i);
      Vector::push_back(&mut stats.current.vote_count, test + 1);
      Vector::swap_remove(&mut stats.current.vote_count, i);
      stats.current.total_votes = stats.current.total_votes + 1;
    }

    //Permissions: Public, VM only.
    public fun reconfig(set: &vector<address>) acquires T {
      Transaction::assert(Transaction::sender() == 0x0, 99190207014010);
      let stats = borrow_global_mut<T>(Transaction::sender());
      // Archive outgoing epoch stats.
      //TODO: limit the size of the history and drop ancient records.
      Vector::push_back(&mut stats.history, *&stats.current);

      stats.current = blank();
      
      init_set(set);
    }

    public fun get_total_votes(sender: &signer): u64 acquires T {
      Transaction::assert(Signer::address_of(sender) == 0x0, 99190208014010);
      *&borrow_global_mut<T>(0x0).current.total_votes
    }

    public fun get_history(): vector<ValidatorSet> acquires T {
      *&borrow_global_mut<T>(0x0).history
    }

    /// TEST HELPERS

    public fun test_helper_inc_vote_addr(sender: &signer, node_addr: address) acquires T {
      Transaction::assert(Signer::address_of(sender) == 0x0, 99190209014010);
      Transaction::assert(Testnet::is_testnet(), 99190210014010);
      inc_vote(node_addr);
    }

}
}
