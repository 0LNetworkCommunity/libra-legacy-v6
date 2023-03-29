address DiemFramework {
  /// This is a simple implementation of a binary vote.
  /// It can be used to instantiate very simple votes, and to programatically initiate actions/events/transactions based on a result.
  /// It's also intended as a demonstration. Developers can use this as a template to create their own tally algorithm and other workflows.
  /// VoteLib itself does not have any storage. It just creates the ballot box, and the methods to query or mutate the ballot box, and ballots.
  /// So this module is a wrapper around VoteLib with simple storage and simple logic.

  module ExampleStandalonePoll {

    use DiemFramework::VoteLib::{Self, Vote};
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

    struct ExamplePoll<ExampleIssueData> has key, store, drop {
      poll: Vote<ExampleIssueData>,
    }

    /// a tally can have any kind of data to support the vote.
    /// this is an example of a binary count.
    /// A dev should also insert data into the tally, to be used in an
    /// action that is triggered on completion.
    struct UsefulTally<IssueData> has store, drop {
      votes_for: u64,
      votes_against: u64,
      voted: vector<address>, // this is a list of voters who have voted. You may prefer to move the voted flag to the end user's address (or do a bloom filter).
      enrollment: vector<address>, // this is a list of voters who are eligible to vote.
      deadline_epoch: u64,
      tally_result: Option<bool>,
      issue_data: IssueData,
    }

    /// a tally can have some arbitrary data payload.
    struct ExampleIssueData has store, drop {
      pay_this_person: address,
      amount: u64,
      description: vector<u8>,
    }

    /// the ability to update tallies is usually restricted to signer
    /// since the signer is the one who can create the GUID::CreateCapability
    /// A third party contract can store that capability to access based on its own vote logic. Danger.
    struct VoteCapability has key {
      guid_cap: GUID::CreateCapability,
    }

    //////// STANDALONE VOTE ////////
    /// Initialize poll struct which will be stored as-is on the account under Vote<Type>.
    /// Developers who need more flexibility, can instead construct the Vote object and then wrap it in another struct on their third party module.
    public fun init_polling_at_address<TallyType: drop + store>(
      sig: &signer,
    ) {
      move_to<ExamplePoll<TallyType>>(sig, ExamplePoll {
        poll: VoteLib::new_poll<TallyType>(),
      });

      // store the capability in the account so the functions below can mutate the ballot and ballot box (by sharing the token/capability needed to create GUIDs)
      // If the developer wants to allow other access control to the Create Capability, they can do so by storing the capability in a different module (i.e. the third party module calling this function)
      let guid_cap = GUID::gen_create_capability(sig);
      move_to(sig, VoteCapability { guid_cap });
    }

    /// If the Vote is standalone at root of address, you can use thie function as long as the CreateCapability is available.
    public fun propose_ballot_by_owner<TallyType: drop + store>(
      sig: &signer,
      tally_type: TallyType,
    ) acquires ExamplePoll, VoteCapability {
      assert!(exists<ExamplePoll<TallyType>>(Signer::address_of(sig)), Errors::invalid_state(ENOT_INITIALIZED));
      let guid_cap = &borrow_global<VoteCapability>(Signer::address_of(sig)).guid_cap;
      propose_ballot_with_capability<TallyType>(guid_cap, tally_type);
    }

     public fun propose_ballot_with_capability<TallyType: drop + store>(
      guid_cap: &GUID::CreateCapability,
      tally_type: TallyType,
    ) acquires ExamplePoll {
      let addr = GUID::get_capability_address(guid_cap);
      let state = borrow_global_mut<ExamplePoll<TallyType>>(addr);
      VoteLib::propose_ballot(&mut state.poll, guid_cap, tally_type);
    }

    public fun standalone_update_tally<TallyType: drop + store> (
      guid_cap: &GUID::CreateCapability,
      uid: &GUID::ID,
      tally_type: TallyType,
    ) acquires ExamplePoll {

      let (found, idx, status_enum, _completed) = standalone_find_anywhere<ExamplePoll<TallyType>>(guid_cap, uid);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      let addr = GUID::get_capability_address(guid_cap);
      let state = borrow_global_mut<ExamplePoll<TallyType>>(addr);

      let b = VoteLib::get_ballot_mut(&mut state.poll, idx, status_enum);
      VoteLib::set_ballot_data(b, tally_type);
    }

    /// tuple if the ballot is (found, its index, its status enum, is it completed)
    public fun standalone_find_anywhere<TallyType: drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID): (bool, u64, u8, bool) acquires ExamplePoll {
      let addr = GUID::get_capability_address(guid_cap);
      let state = borrow_global_mut<ExamplePoll<TallyType>>(addr);
      VoteLib::find_anywhere(&state.poll, uid)
    }


    public fun standalone_complete_and_move<TallyType: drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID, to_status_enum: u8) acquires ExamplePoll {
      let (found, _idx, status_enum, _completed) = standalone_find_anywhere<ExamplePoll<TallyType>>(guid_cap, uid);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      let state = borrow_global_mut<ExamplePoll<TallyType>>(GUID::get_capability_address(guid_cap));
      let b = VoteLib::get_ballot_by_id_mut(&mut state.poll, uid);
      VoteLib::complete_ballot(b);
      VoteLib::move_ballot(&mut state.poll, uid, status_enum, to_status_enum);

    }

    public fun assert_enrolled<TallyType: drop + store>(
      sig: &signer,
      uid: &GUID::ID,
      
    ) acquires ExamplePoll {
      let addr = Signer::address_of(sig);
      let state = borrow_global_mut<ExamplePoll<UsefulTally<TallyType>>>(addr);
      let ballot = VoteLib::get_ballot_by_id(&state.poll, uid);
      let tally_type: &UsefulTally<TallyType>  = VoteLib::get_ballot_type(ballot);
      let enrolled = Vector::contains(&tally_type.enrollment, &addr);
      assert!(enrolled, Errors::invalid_argument(ENOT_ENROLLED));
    }

    public fun assert_not_voted<TallyType: drop + store>(
      sig: &signer,
      uid: &GUID::ID,
      
    ) acquires ExamplePoll {
      let addr = Signer::address_of(sig);
      let state = borrow_global_mut<ExamplePoll<UsefulTally<TallyType>>>(addr);
      let ballot = VoteLib::get_ballot_by_id(&state.poll, uid);
      let tally_type: &UsefulTally<TallyType>  = VoteLib::get_ballot_type(ballot);
      let voted = Vector::contains(&tally_type.voted, &addr);
      assert!(!voted, Errors::invalid_argument(EALREADY_VOTED));
    }

    // The voting handlers are defined by the thrid party module NOT the VoteLib module. The VoteLib module only provides the APIs to move proposals from one list to another. The external contract needs to decide how that should happen.

    public fun vote<TallyType: drop + store>(sig: &signer, vote_address: address, uid: &GUID::ID, vote_for: bool) acquires VoteCapability, ExamplePoll {

      // moving asserts into own scope to drop borrows after checks are complete.
      {

      // expensive calls since we are getting mut data below have the state above, but this is a demo
      assert_enrolled<TallyType>(sig, uid);
      assert_not_voted<TallyType>(sig, uid);

      // get the GUID capability stored here
      let cap = &borrow_global<VoteCapability>(vote_address).guid_cap;
      

      let (found, _idx, status_enum, is_completed) = standalone_find_anywhere<UsefulTally<ExampleIssueData>>(cap, uid);

      assert!(found, Errors::invalid_argument(EINVALID_VOTE));
      assert!(!is_completed, Errors::invalid_argument(EINVALID_VOTE));
      // is a pending ballot
      assert!(status_enum == 0, Errors::invalid_argument(EINVALID_VOTE));

      };

      let addr = Signer::address_of(sig);
      let state = borrow_global_mut<ExamplePoll<UsefulTally<TallyType>>>(addr);
      let ballot = VoteLib::get_ballot_by_id_mut(&mut state.poll, uid);
      let tally_type: &mut UsefulTally<TallyType>  = VoteLib::get_ballot_type_mut(ballot);

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
    fun maybe_tally<TallyType: drop + store>(t: &mut UsefulTally<TallyType>): Option<bool> {


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
    fun maybe_complete<TallyType: drop + store>(tally_type: &mut UsefulTally<TallyType>, cap: &GUID::CreateCapability, uid: &GUID::ID): Option<u8> acquires ExamplePoll {
    if (Option::is_some(&tally_type.tally_result)) {
        let passed = *Option::borrow(&tally_type.tally_result);
        let status_enum = if (passed) {
          APPROVED // approved
        } else { 
          REJECTED // rejected
        };
        // since we have a result lets update the VoteLib state
        standalone_complete_and_move<TallyType>(cap, uid, *&status_enum);
        return Option::some(status_enum)
      };

      Option::none()

    }

  }
}