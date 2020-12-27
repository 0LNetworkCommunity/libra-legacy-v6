
/////////////////////////////////////////////////////////////////////////
// 0L Module
// Polling
/////////////////////////////////////////////////////////////////////////
// 
// This polling module enapsulates functionaliy for a simple type of polling where a surveyor -- who must
// be a validator -- may create a poll where each validator may vote exactly once and votes can be "yes"
// or "no".
// The surveyor is then responsible for tallying the vote. When the vote has been tallied, the result is
// considered final. 
//
address 0x42{
    module Polling{
        use 0x1::Vector;
        use 0x1::Signer;
        use 0x1::LibraSystem;

        resource struct Poll{
          validators_voted: vector<address>,
          poll_yes: u64,
          poll_no: u64
        }

        public fun initialize(sender: &signer) {
          // The user calling initialize() should be the owner of the polling module that th
          // community wishes to use. Other users should not call initialize
          move_to<Poll>(sender, Poll{ validators_voted: Vector::empty<address>(), poll_yes: 0, poll_no: 0 });
        }

        public fun vote(sender: &signer, ledger_address: address, yes_or_no: bool, quantity: u64) acquires Poll {
          let st = borrow_global_mut<Poll>(ledger_address);
        
          // Only validators are allowed to vote
          if (LibraSystem::is_validator(Signer::address_of(sender))) {
            
            // If this sender has already voted, do nothing
            if (Vector::contains<address>(&st.validators_voted, &Signer::address_of(sender))) {return};
            Vector::push_back(&mut st.validators_voted, Signer::address_of(sender));
            
            // Record the vote
            if (yes_or_no) {
              st.poll_yes = st.poll_yes + quantity;
            } else {
              st.poll_no = st.poll_no + quantity;
            };
          }
        }

        public fun yes_votes(ledger_address: address) : u64 acquires Poll {
          let st = borrow_global_mut<Poll>(ledger_address);
          st.poll_yes
        }

        public fun no_votes(ledger_address: address) : u64 acquires Poll {
          let st = borrow_global_mut<Poll>(ledger_address);
          st.poll_no
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
    }
}