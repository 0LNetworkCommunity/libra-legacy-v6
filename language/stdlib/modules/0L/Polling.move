
/////////////////////////////////////////////////////////////////////////
// 0L Module
// Polling
/////////////////////////////////////////////////////////////////////////

address 0x42{
    module Polling{
        //use 0x1::Vector;
        //use 0x1::Signer;

        resource struct Poll{
          poll_yes: u64,
          poll_no: u64
        }

        public fun initialize(sender: &signer){
          // In the actual module, must assert that this is the sender is the association
          move_to<Poll>(sender, Poll{ poll_yes: 0, poll_no: 0 });
        }

        public fun vote(ledger_address: address, yes_or_no: bool, quantity: u64) acquires Poll {
          let st = borrow_global_mut<Poll>(ledger_address);
          
          if (yes_or_no) {
            st.poll_yes = st.poll_yes + quantity;
          } else {
            st.poll_no = st.poll_no + quantity;
          };
        }

        public fun tally(ledger_address: address) : bool acquires Poll {
          let st = borrow_global<Poll>(ledger_address);
          
          let result: bool;
          if (st.poll_yes > st.poll_no) {
            result = true;
          } else {
            result = false;
          };

          result
        }

        // public fun remove_stuff(sender: &signer) acquires State{
        //   let st = borrow_global_mut<State>(Signer::address_of(sender));
        //   let s = &mut st.hist;

        //   Vector::pop_back<u8>(s);
        //   Vector::pop_back<u8>(s);
        //   Vector::remove<u8>(s, 0);
        // }

        // public fun isEmpty(sender: &signer): bool acquires State {
        //   let st = borrow_global<State>(Signer::address_of(sender));
        //   Vector::is_empty(&st.hist)
        // }

        // public fun length(sender: &signer): u64 acquires State{
        //   let st = borrow_global<State>(Signer::address_of(sender));
        //   Vector::length(&st.hist)
        // }

        // public fun contains(sender: &signer, num: u8): bool acquires State {
        //   let st = borrow_global<State>(Signer::address_of(sender));
        //   Vector::contains(&st.hist, &num)
        // }
    }
}