address DiemFramework {
  /// This is a simple implementation of a simple binary choice poll with a deadline.
  /// It can be used to instantiate very simple referenda, and to programatically initiate actions/events/transactions based on a result.
  /// It's also intended as a demonstration. Developers can use this as a template to create their own tally algorithm and other workflows.
  /// VoteLib itself does not have any storage. It just creates the ballot box, and the methods to query or mutate the ballot box, and ballots.
  /// So this module is a wrapper around VoteLib with simple storage and simple logic.

  module BinaryPoll {

    use DiemFramework::VoteLib::{Self, BallotTracker};
    use Std::GUID;
    use Std::Vector;
    use Std::Signer;
    use Std::Errors;
    use Std::Option::{Self, Option};
    use DiemFramework::DiemConfig;

    const ENOT_INITIALIZED: u64 = 0;
    const ENO_BALLOT_FOUND: u64 = 1;
    const ENOT_ENROLLED: u64 = 2;
    const EALREADY_VOTED: u64 = 3;
    const EINVALID_VOTE: u64 = 4;

    // Duplicated from VoteLib
    const PENDING: u8  = 1;
    const APPROVED: u8 = 2;
    const REJECTED: u8 = 3;

    /// We keep a tracker of all the Polls for a given Issue.
    /// VoteLib leverages generics to make ballots have rich data, for custom handlers.
    /// This makes it confusing at first glance, because it creates a russian doll of structs.

    /// In BinaryPoll we have a single place to track every BinaryCounter of a given "issue" that can carry IssueData as a payload. 
    
    /// The "B" generic is deceptively simple. How the state actually looks in memory is:
    /// struct VoteLib::BallotTracker<
    ///     VoteLib::Ballot<
    ///       BinaryPoll::BinaryCounter<
    ///         IssueData { whatever: you_decide }

    struct AllPolls<B> has key, store, drop {
      tracker: BallotTracker<B>,
    }

    /// in VoteLib a TallyType can have any kind of data to support the vote.
    /// In our case it's a BinaryCounter type.
    /// The counter fields are very straightforward.
    /// What may not be straigtforward is the "issue_data" field.
    /// This is a generic field that can be used to store any kind of data.
    /// It could be as simple as an empty struct and just use the name of the struct as the name of the proposal. `VoteForMe {}`
    /// or it could be an address for a payment `PayThisGuy { user: address, amount: u64 }`

    /// The data stored in IssueData can be used to trigger an event lazily when a voter finally crosses the threshold for the count
    // See for example the result of vote() returns the IssueData.

    struct BinaryCounter<IssueData> has store, drop {
      votes_for: u64,
      votes_against: u64,
      voted: vector<address>, // this is a list of voters who have voted. You may prefer to move the voted flag to the end user's address (or do a bloom filter).
      enrollment: vector<address>, // this is a list of voters who are eligible to vote.
      deadline_epoch: u64,
      tally_result: Option<bool>,
      issue_data: IssueData,
    }

    /// the ability to update tallies is usually restricted to signer
    /// since the signer is the one who can create the GUID::CreateCapability
    /// A third party contract can store that capability to access based on its own vote logic. Danger.
    struct VoteCapability has key {
      guid_cap: GUID::CreateCapability,
    }

    //////// INIT ////////
    /// Initialize poll struct which will be stored as-is on the account under BallotTracker<IssueData>.

    /// What is actually happening is a bit of a russian doll. For every "issue y

    /// Developers who need more flexibility, can instead construct the BallotTracker object and then wrap it in another struct on their third party module.
    public fun init_polling_at_address<IssueData: drop + store>(
      sig: &signer,
    ) {
      move_to<AllPolls<IssueData>>(sig, AllPolls {
        tracker: VoteLib::new_tracker<IssueData>(),
      });

      // store the capability in the account so the functions below can mutate the ballot and ballot box (by sharing the token/capability needed to create GUIDs)
      // If the developer wants to allow other access control to the Create Capability, they can do so by storing the capability in a different module (i.e. the third party module calling this function)
      let guid_cap = GUID::gen_create_capability(sig);
      move_to(sig, VoteCapability { guid_cap });
    }


    //////// PROPOSE BALLOT WITH AN ISSUE ////////

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
      VoteLib::propose_ballot(&mut state.tracker, guid_cap, tally_type);
    }

    public fun standalone_update_tally<IssueData: drop + store> (
      guid_cap: &GUID::CreateCapability,
      uid: &GUID::ID,
      tally_type: IssueData,
    ) acquires AllPolls {

      let (found, idx, status_enum, _completed) = standalone_find_anywhere<AllPolls<IssueData>>(guid_cap, uid);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      let addr = GUID::get_capability_address(guid_cap);
      let state = borrow_global_mut<AllPolls<IssueData>>(addr);

      let b = VoteLib::get_ballot_mut(&mut state.tracker, idx, status_enum);
      VoteLib::set_ballot_data(b, tally_type);
    }

    /// tuple if the ballot is (found, its index, its status enum, is it completed)
    public fun standalone_find_anywhere<IssueData: drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID): (bool, u64, u8, bool) acquires AllPolls {
      let addr = GUID::get_capability_address(guid_cap);
      let state = borrow_global_mut<AllPolls<IssueData>>(addr);
      VoteLib::find_anywhere(&state.tracker, uid)
    }


    public fun standalone_complete_and_move<IssueData: drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID, to_status_enum: u8) acquires AllPolls {
      let (found, _idx, status_enum, _completed) = standalone_find_anywhere<AllPolls<IssueData>>(guid_cap, uid);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      let state = borrow_global_mut<AllPolls<IssueData>>(GUID::get_capability_address(guid_cap));
      let b = VoteLib::get_ballot_by_id_mut(&mut state.tracker, uid);
      VoteLib::complete_ballot(b);
      VoteLib::move_ballot(&mut state.tracker, uid, status_enum, to_status_enum);

    }

    public fun assert_enrolled<IssueData: drop + store>(
      sig: &signer,
      uid: &GUID::ID,
      
    ) acquires AllPolls {
      let addr = Signer::address_of(sig);
      let state = borrow_global_mut<AllPolls<BinaryCounter<IssueData>>>(addr);
      let ballot = VoteLib::get_ballot_by_id(&state.tracker, uid);
      let tally_type: &BinaryCounter<IssueData>  = VoteLib::get_type_struct(ballot);
      let enrolled = Vector::contains(&tally_type.enrollment, &addr);
      assert!(enrolled, Errors::invalid_argument(ENOT_ENROLLED));
    }

    public fun assert_not_voted<IssueData: drop + store>(
      sig: &signer,
      uid: &GUID::ID,
      
    ) acquires AllPolls {
      let addr = Signer::address_of(sig);
      let state = borrow_global_mut<AllPolls<BinaryCounter<IssueData>>>(addr);
      let ballot = VoteLib::get_ballot_by_id(&state.tracker, uid);
      let tally_type: &BinaryCounter<IssueData>  = VoteLib::get_type_struct(ballot);
      let voted = Vector::contains(&tally_type.voted, &addr);
      assert!(!voted, Errors::invalid_argument(EALREADY_VOTED));
    }

    // The voting handlers are defined by the thrid party module NOT the VoteLib module. The VoteLib module only provides the APIs to move proposals from one list to another. The external contract needs to decide how that should happen.

    public fun vote<IssueData: drop + store>(sig: &signer, vote_address: address, uid: &GUID::ID, vote_for: bool) acquires VoteCapability, AllPolls {

      // moving asserts into own scope to drop borrows after checks are complete.
      {

      // expensive calls since we are getting mut data below have the state above, but this is a demo
      assert_enrolled<IssueData>(sig, uid);
      assert_not_voted<IssueData>(sig, uid);

      // get the GUID capability stored here
      let cap = &borrow_global<VoteCapability>(vote_address).guid_cap;
      

      let (found, _idx, status_enum, is_completed) = standalone_find_anywhere<BinaryCounter<IssueData>>(cap, uid);

      assert!(found, Errors::invalid_argument(EINVALID_VOTE));
      assert!(!is_completed, Errors::invalid_argument(EINVALID_VOTE));
      // is a pending ballot
      assert!(status_enum == 0, Errors::invalid_argument(EINVALID_VOTE));

      };

      let addr = Signer::address_of(sig);
      let state = borrow_global_mut<AllPolls<BinaryCounter<IssueData>>>(addr);
      let ballot = VoteLib::get_ballot_by_id_mut(&mut state.tracker, uid);
      let tally_type: &mut BinaryCounter<IssueData> = VoteLib::get_type_struct_mut(ballot);

      if (vote_for) {
        tally_type.votes_for = tally_type.votes_for + 1;
      } else {
        tally_type.votes_against = tally_type.votes_against + 1;
      };

      // add the signer to the list of voters
      Vector::push_back(&mut tally_type.voted, addr);
      

      // update the tally
      maybe_tally(tally_type);
    }

    /// just check the tally and mark the result.
    /// this function doesn't move the ballot to a different list, since it doesn't have the outer struct and data needed.
    fun maybe_tally<IssueData: drop + store>(t: &mut BinaryCounter<IssueData>): Option<bool> {


      if (DiemConfig::get_current_epoch() > t.deadline_epoch) {

        if (t.votes_for > t.votes_against) {
          t.tally_result = Option::some(true);
        } else {
          t.tally_result = Option::some(false);
        }

      };

      *&t.tally_result
    }

    /// with access to the outer struct of the Poll, move completed ballots to their correct location: approved or rejected
    /// returns an Option type for approved or rejected, so that the caller can decide what to do with the result.
    fun maybe_complete<IssueData: drop + store>(tally_type: &mut BinaryCounter<IssueData>, cap: &GUID::CreateCapability, uid: &GUID::ID): Option<u8> acquires AllPolls {
    if (Option::is_some(&tally_type.tally_result)) {
        let passed = *Option::borrow(&tally_type.tally_result);
        let status_enum = if (passed) {
          APPROVED // approved
        } else { 
          REJECTED // rejected
        };
        // since we have a result lets update the VoteLib state
        standalone_complete_and_move<IssueData>(cap, uid, *&status_enum);
        return Option::some(status_enum)
      };

      Option::none()

    }

  }
}