
/////////////////////////////////////////////////////////////////////////
// 0L Module
// Demo Persistence
/////////////////////////////////////////////////////////////////////////

address 0x1{
    module PersistenceDemo{
        use 0x1::Vector;
        use 0x1::Signer;

        // Here, I experiment with persistence for now
        // Committing some code that worked successfully
        resource struct State{
          hist: vector<u8>,
        }

        public fun initialize(sender: &signer){
          // In the actual module, must assert that this is the sender is the association
          move_to<State>(sender, State{ hist: Vector::empty() });
        }

        public fun add_stuff(sender: &signer ) acquires State {
          let st = borrow_global_mut<State>(Signer::address_of(sender));
          let s = &mut st.hist;

          Vector::push_back(s, 1);
          Vector::push_back(s, 2);
          Vector::push_back(s, 3);
        }

        public fun remove_stuff(sender: &signer) acquires State{
          let st = borrow_global_mut<State>(Signer::address_of(sender));
          let s = &mut st.hist;

          Vector::pop_back<u8>(s);
          Vector::pop_back<u8>(s);
          Vector::remove<u8>(s, 0);
        }

        public fun isEmpty(sender: &signer): bool acquires State {
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::is_empty(&st.hist)
        }

        public fun length(sender: &signer): u64 acquires State{
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::length(&st.hist)
        }

        public fun contains(sender: &signer, num: u8): bool acquires State {
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::contains(&st.hist, &num)
        }
    }
}