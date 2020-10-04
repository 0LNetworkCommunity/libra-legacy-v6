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

        struct Proposer {
          proposer: vector<address>,
          count: vector<u64>
        }

        // resource struct State {
        //   proposer: vector<address>,
        //   count: vector<u64>
        // }

        resource struct T {
          hist: vector<Proposer>,
          epoch: Proposer
        }

        //Permissions: Public, VM only.
        public fun initialize(vm: &signer){
          Transaction::assert(Signer::address_of(vm) == 0x0, 99190201014010);
          // move_to_sender<State>(State{
          //   proposer: Vector::empty(),
          //   count: Vector::empty() 
          // });

          move_to_sender<T>( T {
            hist: Vector::empty(),
            epoch: Proposer {
              proposer: Vector::empty(),
              count: Vector::empty()
            }
          })
        }



        public fun insert_prop(node_addr: address) acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190203014010);

          let h = borrow_global_mut<T>(Transaction::sender());
          Vector::push_back(&mut h.epoch.proposer, node_addr);
          Vector::push_back(&mut h.epoch.count, 0);
        }

        public fun inc_prop(node_addr: address) acquires T {
          Transaction::assert(Transaction::sender() == 0x0, 99190204014010);

          let t = borrow_global_mut<T>(Transaction::sender());
          let (_, i) = Vector::index_of<address>(&mut t.epoch.proposer, &node_addr);
          
          // Vector::push_back(&mut st.count, 1);
          let test = *Vector::borrow<u64>(&mut t.epoch.count, i);
          
          Vector::push_back(&mut t.epoch.count, test + 1);

          Vector::swap_remove(&mut t.epoch.count, i);

          // test = test + &mut 1;
          print(&t.epoch.count);
          // Vector::swap_remove(&mut st.count, i);
        }
        

        // public fun insert_proposer(node_addr: address) acquires State {
        //   Transaction::assert(Transaction::sender() == 0x0, 99190202014010);

        //   let st = borrow_global_mut<State>(Transaction::sender());
        //   Vector::push_back(&mut st.proposer, node_addr);
        //   Vector::push_back(&mut st.count, 0);
        // }

        // public fun inc_proposer(node_addr: address) acquires State {
        //   Transaction::assert(Transaction::sender() == 0x0, 99190205014010);

        //   let st = borrow_global_mut<State>(Transaction::sender());
        //   let (_, i) = Vector::index_of<address>(&mut st.proposer, &node_addr);
          
        //   // Vector::push_back(&mut st.count, 1);
        //   let test = *Vector::borrow<u64>(&mut st.count, i);
          
        //   Vector::push_back(&mut st.count, test + 1);

        //   Vector::swap_remove(&mut st.count, i);

        //   // test = test + &mut 1;
        //   print(&st.count);
        //   // Vector::swap_remove(&mut st.count, i);
        // }

        // public fun remove_stuff() acquires State{
        //   let st = borrow_global_mut<State>(Transaction::sender());
        //   let s = &mut st.proposer;

        //   Vector::pop_back<u8>(s);
        //   Vector::pop_back<u8>(s);
        //   Vector::remove<u8>(s, 0);
        // }
        // public fun get(i: u64): address acquires State {
        //   let st = borrow_global<State>(Transaction::sender());
        //   *Vector::borrow<address>(&st.proposer, i)
        // }

        // public fun isEmpty(): bool acquires State {
        //   let st = borrow_global<State>(Transaction::sender());
        //   Vector::is_empty(&st.proposer)
        // }

        // public fun length(): u64 acquires State{
        //   let st = borrow_global<State>(Transaction::sender());
        //   Vector::length(&st.proposer)
        // }

        // public fun contains(addr: address): bool acquires State {
        //   let st = borrow_global<State>(Transaction::sender());
        //   Vector::contains(&st.proposer, &addr)
        // }
    }
}
