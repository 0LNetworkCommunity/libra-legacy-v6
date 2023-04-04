address DiemFramework {
  /// See BinaryTally.move for the details docs on developing your own poll.

  /// This is a simple implementation of a simple binary choice poll with a deadline.
  /// It can be used to instantiate very simple referenda, and to programatically initiate actions/events/transactions based on a result.
  /// It's also intended as a demonstration. Developers can use this as a template to create their own tally algorithm and other workflows.

  module TurnkeyBinaryPoll {

    use DiemFramework::Ballot::{Self, BallotTracker};
    use DiemFramework::BinaryTally::{Self, BinaryTally};
    use Std::GUID;
    use Std::Errors;
    use Std::Signer;
    use Std::Option::Option;

    const ENOT_INITIALIZED: u64 = 0;
    const ENO_BALLOT_FOUND: u64 = 1;
    const ENOT_ENROLLED: u64 = 2;
    const EALREADY_VOTED: u64 = 3;
    const EINVALID_VOTE: u64 = 4;

    // Duplicated from Ballot
    const PENDING: u8  = 1;
    const APPROVED: u8 = 2;
    const REJECTED: u8 = 3;


    /// In BinaryPoll we have a single place to track every BinaryTally of a given "issue" that can carry IssueData as a payload. 
    
    /// The "B" generic is deceptively simple. How the state actually looks in memory is:
    /// struct Ballot::BallotTracker<
    ///     Ballot::Ballot<
    ///       BinaryPoll::BinaryTally<
    ///         IssueData { whatever: you_decide }

    struct AllPolls<B> has key, store, drop {
      tracker: BallotTracker<B>,
    }

    /// the ability to update tallies is usually restricted to signer
    /// since the signer is the one who can create the GUID::CreateCapability
    /// A third party contract can store that capability to access based on its own vote logic. Danger.
    struct VoteCapability has key {
      guid_cap: GUID::CreateCapability,
    }

    /// Developers who need more flexibility, can instead construct the BallotTracker object and then wrap it in another struct on their third party module.
    public fun init_polling_at_address<IssueData: drop + store>(
      sig: &signer,
    ) {
      move_to<AllPolls<IssueData>>(sig, AllPolls {
        tracker: Ballot::new_tracker<IssueData>(),
      });

      // store the capability in the account so the functions below can mutate the ballot and ballot box (by sharing the token/capability needed to create GUIDs)
      // If the developer wants to allow other access control to the Create Capability, they can do so by storing the capability in a different module (i.e. the third party module calling this function)
      let guid_cap = GUID::gen_create_capability(sig);
      move_to(sig, VoteCapability { guid_cap });
    }

    /// If the BallotTracker is standalone at root of address, you can use thie function as long as the CreateCapability is available.
    public fun propose_ballot_by_owner<IssueData: drop + store>(
      sig: &signer,
      tally_type: IssueData,
    ) acquires AllPolls, VoteCapability {
      assert!(exists<AllPolls<IssueData>>(Signer::address_of(sig)), Errors::invalid_state(ENOT_INITIALIZED));
      let guid_cap = &borrow_global<VoteCapability>(Signer::address_of(sig)).guid_cap;
      propose_ballot_with_capability<IssueData>(guid_cap, tally_type);
    }

     public fun propose_ballot_with_capability<IssueData: drop + store>(
      guid_cap: &GUID::CreateCapability,
      tally_type: IssueData,
    ) acquires AllPolls {
      let addr = GUID::get_capability_address(guid_cap);
      let state = borrow_global_mut<AllPolls<IssueData>>(addr);
      Ballot::propose_ballot(&mut state.tracker, guid_cap, tally_type);
    }
    
    

    /// Public helper to get data on an issue without privileges. Returns tuple if the ballot is (found, its index, its status enum, is it completed)
    public fun find_by_address<IssueData: drop + store>(poll_address: address, uid: &GUID::ID): (bool, u64, u8, bool) acquires AllPolls {
      let state = borrow_global<AllPolls<IssueData>>(poll_address);
      Ballot::find_anywhere(&state.tracker, uid)
    }

    //////// API ////////
    
    public fun propose_ballot_owner_script<IssueData: drop + store>(
      sig: &signer,
      tally_type: IssueData,
    ) acquires AllPolls, VoteCapability{
      propose_ballot_by_owner<IssueData>(sig, tally_type);
    }

    public fun add_remove_voters<IssueData: drop + store>(
      sig: &signer,
      voters: vector<address>,
      uid: &GUID::ID,
      add_remove: bool,
    ) acquires AllPolls {
      let addr = Signer::address_of(sig);
      let state = borrow_global_mut<AllPolls<BinaryTally<IssueData>>>(addr);
      BinaryTally::update_enrollment<IssueData>(&mut state.tracker, uid, voters, add_remove);
    }

    // Use this Vote API for a handler that is called by the voter and then lazily executes a different function based on the return.
    public fun vote<IssueData: drop + store>(
      sig: &signer,
      vote_address: address,
      uid: &GUID::ID,
      for_against: bool,
    ): Option<bool>  acquires AllPolls { //returns some() if the vote was completed, and true/false if it passed.
      let state = borrow_global_mut<AllPolls<BinaryTally<IssueData>>>(vote_address);
      BinaryTally::vote<IssueData>(sig, &mut state.tracker, uid, for_against)
    }


  }

  
}