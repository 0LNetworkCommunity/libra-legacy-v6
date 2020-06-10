address 0x0{
    module PersistenceTrial{
        use 0x0::Vector;
        use 0x0::Transaction;
    
    
        // Here, I experiment with persistence for now
        // Committing some code that worked successfully
        resource struct State{
          hist: vector<u8>,
        }
    
        public fun initialize(){
          // In the actual module, must assert that this is the sender is the association
          move_to_sender<State>(State{ hist: Vector::empty() });
        }
    
        public fun add_stuff() acquires State {
          let st = borrow_global_mut<State>(Transaction::sender());
          let s = &mut st.hist;
    
          Vector::push_back(s, 1);
          Vector::push_back(s, 2);
          Vector::push_back(s, 3);
        }
    
        public fun remove_stuff() acquires State{
          let st = borrow_global_mut<State>(Transaction::sender());
          let s = &mut st.hist;
    
          Vector::pop_back<u8>(s);
          Vector::pop_back<u8>(s);
          Vector::remove<u8>(s, 0);
        }
    
        public fun isEmpty(): bool acquires State {
          let st = borrow_global<State>(Transaction::sender());
          Vector::is_empty(&st.hist)
        }
    
        public fun length(): u64 acquires State{
          let st = borrow_global<State>(Transaction::sender());
          Vector::length(&st.hist)
        }
    
        public fun contains(num: u8): bool acquires State {
          let st = borrow_global<State>(Transaction::sender());
          Vector::contains(&st.hist, &num)
        }
    }
}