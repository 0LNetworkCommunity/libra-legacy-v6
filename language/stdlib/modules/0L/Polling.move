
/////////////////////////////////////////////////////////////////////////
// 0L Module
// Polling
/////////////////////////////////////////////////////////////////////////
// 
// This polling module enapsulates functionaliy for a simple type of polling where the account controlling the
// module ("The Surveyor") may create a poll, in which each validator may vote exactly once. Votes may be "yes" 
// or "no". Voters cannot re-vote to change their vote.
//
// The surveyor is then responsible for tallying the vote. When the vote has been tallied, the result of the
// poll is considered final and no further votes may be cast. 
//
address 0x42{
    module Polling{
        use 0x1::Vector;
        use 0x1::Signer;
        use 0x1::LibraSystem;

        resource struct Poll{
          validators_voted: vector<address>,
          poll_yes: u64,
          poll_no: u64,
          vote_closed: bool
        }

        // The account calling initialize() should be the owner of the polling module that the
        // community wishes to use. Other users should not call initialize
        public fun initialize(sender: &signer) {
          move_to<Poll>(sender, Poll{ validators_voted: Vector::empty<address>(), poll_yes: 0, poll_no: 0, vote_closed: false });
        }

        // Method may be called by any validator. Vote will be included as long as voting is not yet closedd
        public fun vote(sender: &signer, ledger_address: address, yes_or_no: bool) acquires Poll {
          let st = borrow_global_mut<Poll>(ledger_address);
        
          // If the vote is already closed, then return
          if (st.vote_closed) return;

          // Only validators are allowed to vote
          if (LibraSystem::is_validator(Signer::address_of(sender))) {
            
            // If this sender has already voted, do nothing
            if (Vector::contains<address>(&st.validators_voted, &Signer::address_of(sender))) {return};
            
            // If they haven't voted, note that they are now voting
            Vector::push_back(&mut st.validators_voted, Signer::address_of(sender));
            
            // Record the vote
            if (yes_or_no) {
              st.poll_yes = st.poll_yes + 1;
            } else {
              st.poll_no = st.poll_no + 1;
            };
          }
        }

        // Returns the total number of 'yes' votes so far
        public fun get_yes_votes(ledger_address: address) : u64 acquires Poll {
          let st = borrow_global<Poll>(ledger_address);
          st.poll_yes
        }

        // Returns the total number of 'no' votes so far
        public fun get_no_votes(ledger_address: address) : u64 acquires Poll {
          let st = borrow_global<Poll>(ledger_address);
          st.poll_no
        }

        // Returns true if voting is closed and the result is final
        public fun get_result_is_final(ledger_address: address) : bool acquires Poll {
          let st = borrow_global<Poll>(ledger_address);
          st.vote_closed
        }

        // True if the result of the vote is currently 'yes'
        public fun current_tally_is_yes(ledger_address: address) : bool acquires Poll {
          let st = borrow_global<Poll>(ledger_address);
          st.poll_yes > st.poll_no
        }

        // True if the result of the vote is currently 'no'
        public fun current_tally_is_no(ledger_address: address) : bool acquires Poll {
          let st = borrow_global<Poll>(ledger_address);
          st.poll_yes < st.poll_no
        }

        // True if the result of the vote is currently 'tie'
        public fun current_tally_is_tie(ledger_address: address) : bool acquires Poll {
          let st = borrow_global<Poll>(ledger_address);
          st.poll_yes == st.poll_no
        }

        // Tally the vote. Can only be called by the owner of the modudle
        public fun tally(sender: &signer, ledger_address: address) acquires Poll {
          let st = borrow_global_mut<Poll>(ledger_address);
          
          // Can't re-tally after the vote is already closed
          if (st.vote_closed) return;

          // Only the owner of the account hosting the polling modulee can call tally
          if (ledger_address == Signer::address_of(sender)) {
            // Finalize the result of the vote. No further voting is possible
            st.vote_closed = true;
          };
        }
    }
}