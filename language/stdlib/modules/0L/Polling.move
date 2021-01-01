
/////////////////////////////////////////////////////////////////////////
// 0L Module
// Polling
/////////////////////////////////////////////////////////////////////////
// 
// This polling module enapsulates functionaliy for a simple type of polling that supports the creation of 
// multiple polls. Polls can be created by any account.
// 
// It works like this:
// 
// There is a single account that owns the module, and by convention, all polls are managed there. This account
// does not have any special power over the polls. It just serves to specify a commonly agreed-upon address
// where polling will occur. The owner of the module must call initialize() once when the module is first created.
//
// Once the module is created and initialized, then any user of the system may create a new poll by calling
// create_poll(). The method will return a u64 and that will be the id of the poll, which is then used by the other
// methods in this module to identify which poll is being voted, tallied, etc.
//
// The creator of a poll is known as "The Surveyor" for that poll. Only the surveyor for a poll may call tally()
// on that poll to finalize the results. When the vote has been tallied, the result of the poll is considered 
// final and no further votes may be cast. 
//
// At this time, only validators may vote in polls.
//
address 0x42{
    module Polling{
        use 0x1::Vector;
        use 0x1::Signer;
        use 0x1::LibraSystem;

        resource struct PollSet{
          polls: vector<Poll>,
        }

        struct Poll{
          surveyor_address: address,
          validators_voted: vector<address>,
          poll_yes: u64,
          poll_no: u64,
          vote_closed: bool
        }

        // The account calling initialize() should be the owner of the polling module that the
        // community wishes to use. Other users should not call initialize
        public fun initialize(sender: &signer) {
          let poll_set = PollSet{ polls: Vector::empty<Poll>() };
          move_to<PollSet>(sender, poll_set);
        }

        public fun create_poll(sender: &signer, ledger_address: address) : u64 acquires PollSet {
          let poll_set = borrow_global_mut<PollSet>(ledger_address);
          let index = Vector::length(&mut poll_set.polls);
          let surveyor_address = Signer::address_of(sender);
          let poll = Poll{surveyor_address: surveyor_address, validators_voted: Vector::empty<address>(), poll_yes: 0, poll_no: 0, vote_closed: false };
          Vector::push_back(&mut poll_set.polls, poll);
          index
        }

        // Method may be called by any validator. Vote will be included as long as voting is not yet closedd
        public fun vote(sender: &signer, ledger_address: address, poll_index: u64, yes_or_no: bool) acquires PollSet {
          let poll_set = borrow_global_mut<PollSet>(ledger_address);
          let poll = Vector::borrow_mut(&mut poll_set.polls, poll_index);

          // If the vote is already closed, then return
          if (poll.vote_closed) return;

          // Only validators are allowed to vote
          if (LibraSystem::is_validator(Signer::address_of(sender))) {
            
            // If this sender has already voted, do nothing
            if (Vector::contains<address>(&poll.validators_voted, &Signer::address_of(sender))) {return};
            
            // If they haven't voted, note that they are now voting
            Vector::push_back(&mut poll.validators_voted, Signer::address_of(sender));
            
            // Record the vote
            if (yes_or_no) {
              poll.poll_yes = poll.poll_yes + 1;
            } else {
              poll.poll_no = poll.poll_no + 1;
            };
          }
        }

        // Returns the current tally, regardless of whether all votes have been cast
        public fun get_tally(ledger_address: address, poll_index: u64) : (u64, u64) acquires PollSet {
          let poll_set = borrow_global_mut<PollSet>(ledger_address);
          let poll = Vector::borrow_mut(&mut poll_set.polls, poll_index);
          (poll.poll_yes, poll.poll_no)
        }

        // Returns true if voting is closed and the result is final
        public fun get_result_is_final(ledger_address: address, poll_index: u64) : bool acquires PollSet {
          let poll_set = borrow_global_mut<PollSet>(ledger_address);
          let poll = Vector::borrow_mut(&mut poll_set.polls, poll_index);
          poll.vote_closed
        }

        // Tally the vote. Can only be called by the owner of the modudle
        public fun tally(sender: &signer, ledger_address: address, poll_index: u64) acquires PollSet {
          let poll_set = borrow_global_mut<PollSet>(ledger_address);
          let poll = Vector::borrow_mut(&mut poll_set.polls, poll_index);
          
          // Can't re-tally after the vote is already closed
          if (poll.vote_closed) return;

          // Only the creator of the poll can tally
          if (poll.surveyor_address == Signer::address_of(sender)) {
            // Finalize the result of the vote. No further voting is possible
            poll.vote_closed = true;
          };
        }
    }
}