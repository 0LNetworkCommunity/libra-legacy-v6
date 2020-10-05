/////////////////////////////////////////////////////////////////////////
// 0L Module
// Demo Persistence
/////////////////////////////////////////////////////////////////////////

address 0x0{
    module AltStats{
        use 0x0::Vector;
        use 0x0::Transaction;
        use 0x0::Signer;
        use 0x0::Debug::print;

        struct ValidatorSet {
          addr: vector<address>,
          prop_count: vector<u64>,
          vote_count: vector<u64>
        }

        resource struct T {
          history: vector<ValidatorSet>,
          current: ValidatorSet,
          total_votes: u64,
          total_props: u64,
        }

        //Permissions: Public, VM only.
        public fun initialize(vm: &signer){
          Transaction::assert(Signer::address_of(vm) == 0x0, 99190201014010);
          move_to_sender<T>( T {
            history: Vector::empty(),
            current: ValidatorSet {
              addr: Vector::empty(),
              prop_count: Vector::empty(),
              vote_count: Vector::empty()
            },
            total_votes: 0,
            total_props: 0,
          })
        }

        //Permissions: Public, VM only.
      public fun init_address(node_addr: address) acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190204014010);
          let stats = borrow_global_mut<T>(Transaction::sender());
          Vector::push_back(&mut stats.current.addr, node_addr);
          Vector::push_back(&mut stats.current.prop_count, 0);
          Vector::push_back(&mut stats.current.vote_count, 0);
        }

        public fun init_set(set: vector<address>) acquires T{
          Transaction::assert(Transaction::sender() == 0x0, 99190204014010);
          let length = Vector::length<address>(&set);
          let k = 0;
          while (k < length) {
            let node_address = *(Vector::borrow<address>(&set, k));
            print(&node_address);
            init_address(node_address);
            k = k + 1;
          }
        }

        public fun process_set_votes(set: vector<address>) acquires T{
          Transaction::assert(Transaction::sender() == 0x0, 99190204014010);
          let length = Vector::length<address>(&set);
          let k = 0;
          while (k < length) {
            let node_address = *(Vector::borrow<address>(&set, k));
            print(&node_address);
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

        // public fun node_history (epoch: u64): u64 acquires T {

        // }

        // public fun current_network_stats (): u64 acquires T {

        // }

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
        }
        
        //TODO: Duplicate code.
        //Permissions: Public, VM only.
        public fun inc_vote(node_addr: address) acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190206014010);
          let stats = borrow_global_mut<T>(Transaction::sender());
          let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
          let test = *Vector::borrow<u64>(&mut stats.current.vote_count, i);
          Vector::push_back(&mut stats.current.vote_count, test + 1);
          Vector::swap_remove(&mut stats.current.vote_count, i);
        }

        //Permissions: Public, VM only.
        public fun reconfig() acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190207014010);
          let stats = borrow_global_mut<T>(Transaction::sender());
          Vector::push_back(&mut stats.history, *&stats.current);

          //TODO: limit the size of the history and drop records.
          stats.current = ValidatorSet {
            addr: Vector::empty(),
            prop_count: Vector::empty(),
            vote_count: Vector::empty()
          };
        }

        // public fun get_history(): vector<ValidatorSet> acquires T {
        //   Transaction::assert(Transaction::sender() == 0x0, 99190208014010);
        //   *&borrow_global_mut<T>(Transaction::sender()).history

        // }
    }
}
