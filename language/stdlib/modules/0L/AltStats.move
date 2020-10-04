/////////////////////////////////////////////////////////////////////////
// 0L Module
// Demo Persistence
/////////////////////////////////////////////////////////////////////////

address 0x0{
    module AltStats{
        use 0x0::Vector;
        use 0x0::Transaction;
        use 0x0::Signer;

        // use 0x0::Debug::print;

        struct ValidatorSet {
          addr: vector<address>,
          prop_count: vector<u64>,
          vote_count: vector<u64>
        }

        // resource struct State {
        //   addr: vector<address>,
        //   prop_prop_count: vector<u64>
        // }

        resource struct T {
          history: vector<ValidatorSet>,
          current: ValidatorSet
        }

        //Permissions: Public, VM only.
        public fun initialize(vm: &signer){
          Transaction::assert(Signer::address_of(vm) == 0x0, 99190201014010);
          // move_to_sender<State>(State{
          //   addr: Vector::empty(),
          //   prop_prop_count: Vector::empty() 
          // });

          move_to_sender<T>( T {
            history: Vector::empty(),
            current: ValidatorSet {
              addr: Vector::empty(),
              prop_count: Vector::empty(),
              vote_count: Vector::empty()
            }
          })
        }

        public fun node_current_votes(node_addr: address): u64 acquires T {

          // return (proposed blocks count, votes)

          Transaction::assert(Transaction::sender() == 0x0, 99190204014010);
          let stats = borrow_global_mut<T>(Transaction::sender());
          let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
          *Vector::borrow<u64>(&mut stats.current.vote_count, i)
        }

        // public fun node_history (epoch: u64): u64 acquires T {

        // }

        // public fun current_network_stats (): u64 acquires T {

        // }

        // public fun network_history (epoch: u64): u64 acquires T {

        // }

        public fun insert_prop(node_addr: address) acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190203014010);
          let stats = borrow_global_mut<T>(Transaction::sender());
          Vector::push_back(&mut stats.current.addr, node_addr);
          Vector::push_back(&mut stats.current.prop_count, 0);
          Vector::push_back(&mut stats.current.vote_count, 0);
        }

        public fun inc_prop(node_addr: address) acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190204014010);
          let stats = borrow_global_mut<T>(Transaction::sender());
          let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
          let test = *Vector::borrow<u64>(&mut stats.current.prop_count, i);
          Vector::push_back(&mut stats.current.prop_count, test + 1);
          Vector::swap_remove(&mut stats.current.prop_count, i);
        }
        
        //TODO: Duplicate code.
        public fun inc_vote(node_addr: address) acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190204014010);
          let stats = borrow_global_mut<T>(Transaction::sender());
          let (_, i) = Vector::index_of<address>(&mut stats.current.addr, &node_addr);
          let test = *Vector::borrow<u64>(&mut stats.current.vote_count, i);
          Vector::push_back(&mut stats.current.vote_count, test + 1);
          Vector::swap_remove(&mut stats.current.vote_count, i);
        }

        public fun reconfig() acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190204014010);
          let stats = borrow_global_mut<T>(Transaction::sender());
          Vector::push_back(&mut stats.history, *&stats.current);

          //TODO: limit the size of the history and drop records.
          stats.current = ValidatorSet {
            addr: Vector::empty(),
            prop_count: Vector::empty(),
            vote_count: Vector::empty()
          };
        }  

        // public fun insert_addr(node_addr: address) acquires State {
        //   Transaction::assert(Transaction::sender() == 0x0, 99190202014010);

        //   let st = borrow_global_mut<State>(Transaction::sender());
        //   Vector::push_back(&mut st.addr, node_addr);
        //   Vector::push_back(&mut st.prop_count, 0);
        // }

        // public fun inc_addr(node_addr: address) acquires State {
        //   Transaction::assert(Transaction::sender() == 0x0, 99190205014010);

        //   let st = borrow_global_mut<State>(Transaction::sender());
        //   let (_, i) = Vector::index_of<address>(&mut st.addr, &node_addr);
          
        //   // Vector::push_back(&mut st.prop_count, 1);
        //   let test = *Vector::borrow<u64>(&mut st.prop_count, i);
          
        //   Vector::push_back(&mut st.prop_count, test + 1);

        //   Vector::swap_remove(&mut st.prop_count, i);

        //   // test = test + &mut 1;
        //   print(&st.prop_count);
        //   // Vector::swap_remove(&mut st.prop_count, i);
        // }

        // public fun remove_stuff() acquires State{
        //   let st = borrow_global_mut<State>(Transaction::sender());
        //   let s = &mut st.addr;

        //   Vector::pop_back<u8>(s);
        //   Vector::pop_back<u8>(s);
        //   Vector::remove<u8>(s, 0);
        // }
        // public fun get(i: u64): address acquires State {
        //   let st = borrow_global<State>(Transaction::sender());
        //   *Vector::borrow<address>(&st.addr, i)
        // }

        // public fun isEmpty(): bool acquires State {
        //   let st = borrow_global<State>(Transaction::sender());
        //   Vector::is_empty(&st.addr)
        // }

        // public fun length(): u64 acquires State{
        //   let st = borrow_global<State>(Transaction::sender());
        //   Vector::length(&st.addr)
        // }

        // public fun contains(addr: address): bool acquires State {
        //   let st = borrow_global<State>(Transaction::sender());
        //   Vector::contains(&st.addr, &addr)
        // }
    }
}
