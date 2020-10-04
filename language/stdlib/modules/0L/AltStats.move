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



        // Here, I experiment with persistence for now
        // Committing some code that worked successfully
        resource struct State{
          proposer: vector<address>,
          count: vector<u64>
        }

        //Permissions: Public, VM only.
        public fun initialize(vm: &signer){
          Transaction::assert(Signer::address_of(vm) == 0x0, 99190201014010);
          move_to_sender<State>(State{
            proposer: Vector::empty(),
            count: Vector::empty() 
          });
        }

        public fun insert_proposer(node_addr: address) acquires State {
          Transaction::assert(Transaction::sender() == 0x0, 99190201014010);

          let st = borrow_global_mut<State>(Transaction::sender());
          Vector::push_back(&mut st.proposer, node_addr);
          Vector::push_back(&mut st.count, 0);
        }
        
        public fun inc_proposer(node_addr: address) acquires State {
          Transaction::assert(Transaction::sender() == 0x0, 99190201014010);

          let st = borrow_global_mut<State>(Transaction::sender());
          let (_, i) = Vector::index_of<address>(&mut st.proposer, &node_addr);
          
          // Vector::push_back(&mut st.count, 1);
          let test = *Vector::borrow<u64>(&mut st.count, i);
          
          Vector::push_back(&mut st.count, test + 1);

          Vector::swap_remove(&mut st.count, i);

          // test = test + &mut 1;
          print(&st.count);
          // Vector::swap_remove(&mut st.count, i);
        }

        // public fun remove_stuff() acquires State{
        //   let st = borrow_global_mut<State>(Transaction::sender());
        //   let s = &mut st.proposer;

        //   Vector::pop_back<u8>(s);
        //   Vector::pop_back<u8>(s);
        //   Vector::remove<u8>(s, 0);
        // }
        public fun get(i: u64): address acquires State {
          let st = borrow_global<State>(Transaction::sender());
          *Vector::borrow<address>(&st.proposer, i)
        }

        public fun isEmpty(): bool acquires State {
          let st = borrow_global<State>(Transaction::sender());
          Vector::is_empty(&st.proposer)
        }

        public fun length(): u64 acquires State{
          let st = borrow_global<State>(Transaction::sender());
          Vector::length(&st.proposer)
        }

        public fun contains(addr: address): bool acquires State {
          let st = borrow_global<State>(Transaction::sender());
          Vector::contains(&st.proposer, &addr)
        }
    }
}
