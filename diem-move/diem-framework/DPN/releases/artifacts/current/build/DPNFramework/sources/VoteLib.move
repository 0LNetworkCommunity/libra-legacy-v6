
address DiemFramework {
    module VoteLib {
    use Std::Vector;
    use Std::GUID::{Self, ID};
    use Std::Errors;

    /// The ballot has already been completed.
    const ECOMPLETED: u64 = 300010; 
    /// The number of votes cast cannot be greater than the max number of votes available from enrollment.
    const EVOTES_GREATER_THAN_ENROLLMENT: u64 = 300011;
    /// The threshold curve parameters are wrong. The curve is not decreasing.
    const EVOTE_CALC_PARAMS: u64 = 300012;
    /// Voters cannot vote twice, but they can retract a vote
    const EALREADY_VOTED: u64 = 300013;
    /// The voter has not voted yet. Cannot retract a vote.
    const ENOT_VOTED: u64 = 300014;
    /// No ballot found under that GUID
    const ENO_BALLOT_FOUND: u64 = 300015;
    /// Bad status enum
    const EBAD_STATUS_ENUM: u64 = 300016;

    // TODO: These may be variable on a per project basis. And these
    // should just be defaults.
    const PCT_SCALE: u64 = 10000;
    const LOW_TURNOUT_X1: u64 = 1250;// 12.5% turnout
    const HIGH_TURNOUT_X2: u64 = 8750;// 87.5% turnout
    const THRESH_AT_LOW_TURNOUT_Y1: u64 = 10000;// 100% pass at low turnout
    const THRESH_AT_HIGH_TURNOUT_Y2: u64 = 5100;// 51% pass at high turnout
    const MINORITY_EXT_MARGIN: u64 = 500; // The change in vote gap between majority and minority must have changed in the last day by this amount to for the minority to get an extension.

    // poor man's enum for the ballot status. Wen enum?
    const PENDING: u8  = 1;
    const APPROVED: u8 = 2;
    const REJECTED: u8 = 3;


    // Participation is a Library for Creating Ballots or Polls
    // Polls is a helper to keep track of Ballots but it is not required.

    // usually a smart contract will be the one to create the ballots 
    // connected to some contract logic.

    // A ballot that passes, can be used for lazy triggering of actions related to the ballot.

    // The contract may have multiple ballots at a given time.
    // Historical completed ballots are also stored in a separate vector.
    // Developers can use Vote struct to instantiate an election.
    // or then can use Ballot, for a custom voting solution.
    // lastly the developer can simply wrap refereundum into another struct with more context.

    struct Vote<TallyType> has key, store, drop {
      ballots_pending: vector<Ballot<TallyType>>,
      ballots_approved: vector<Ballot<TallyType>>,
      ballots_rejected: vector<Ballot<TallyType>>,
    }

    struct Ballot<TallyType> has key, store, drop {
      guid: GUID::GUID,
      // issue: IssueData, // issue is the data of what is being decided.
      tally_type: TallyType, // a tally type includes how the count happens and the deadline.
      completed: bool,
    }


    //////// FOR STANDALONE POLLS ////////
    /// Developers may simply initialize a poll at the root level of their address, Or they can wrap the poll in another struct. There are different APIs for each. One group of APIs are for standalone polls which require the GUID CreateCapability. The other group of APIs are for polls that are wrapped in another struct, and this one assumes the sender can access a mutable instance of the Vote struct, which may be stored under a key of another Struct.


    //////// POLL METHODS ////////
    // For
    /// The poll constructor. Use this to create a poll that you are wrapping in another struct. 
    // E.g. `struct Mystruct<TallyType> has key { poll: Vote<TallyType> }`
    public fun new_poll<TallyType: copy + drop + store>(): Vote<TallyType> {
      Vote {
        ballots_pending: Vector::empty(),
        ballots_approved: Vector::empty(),
        ballots_rejected: Vector::empty(),
      }
    }

    /// If you have a mutable Vote instance AND you have the GUID Create Capability, you can use this to create a ballot.
    public fun propose_ballot<TallyType: copy + drop + store>(
      poll: &mut Vote<TallyType>,
      guid_cap: &GUID::CreateCapability, // whoever is ceating this issue needs access to the GUID creation capability
      // issue: IssueData,
      tally_type: TallyType,
    ): &mut Ballot<TallyType>  {
      let b = Ballot {

        guid: GUID::create_with_capability(@0xDEADBEEF, guid_cap), // address is ignored.
        // issue,
        tally_type,
        completed: false,
       
      };
      let len = Vector::length(&poll.ballots_pending);
      Vector::push_back(&mut poll.ballots_pending, b);
      Vector::borrow_mut(&mut poll.ballots_pending, len + 1)
    }


    // with only a GUID, return a ballot mutable
    public fun get_ballot_by_id_mut<TallyType: copy + drop + store> (
      poll: &mut Vote<TallyType>,
      guid: &GUID::ID,
    ): &mut Ballot<TallyType> {

      let (found, idx, status_enum, _completed) = find_anywhere(poll, guid);

      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      get_ballot_mut<TallyType>(poll, idx, status_enum)
    }


    /// private function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.
    public fun get_ballot_mut<TallyType: copy + drop + store> (
      poll: &mut Vote<TallyType>,
      idx: u64, 
      status_enum: u8
    ): &mut Ballot<TallyType> {

      let list = get_list_ballots_by_enum_mut<TallyType>(poll, status_enum);

      assert!(Vector::length(list) > idx, Errors::invalid_argument(ENO_BALLOT_FOUND));

      Vector::borrow_mut(list, idx)
    }


    /// find the ballot wherever it is: pending, approved, rejected.
    /// returns a tuple of (is_found: bool, index: u64, status_enum: u8, is_complete: bool)
    public fun find_anywhere<TallyType: copy + drop + store> (
      poll: &Vote<TallyType>,
      proposal_guid: &GUID::ID,
    ): (bool, u64, u8, bool) {

     // looking in pending
     let (found, idx) = find_index_of_ballot(poll, proposal_guid, PENDING);
     if (found) {
      let complete = is_completed(Vector::borrow(&poll.ballots_pending, idx));
       return (true, idx, PENDING, complete)
     };

     // looking in approved
      let (found, idx) = find_index_of_ballot(poll, proposal_guid, APPROVED);
      if (found) {
        let complete = is_completed(Vector::borrow(&poll.ballots_approved, idx));
        return (true, idx, APPROVED, complete)
      };

     // looking in rejected
      let (found, idx) = find_index_of_ballot(poll, proposal_guid, REJECTED);
      if (found) {
        let complete = is_completed(Vector::borrow(&poll.ballots_rejected, idx));
        return (true, idx, REJECTED, complete)
      };

      (false, 0, 0, false)
    }

   /// returns a tuple of (is_found: bool, index: u64, status_enum: u8, is_complete: bool)
    public fun find_anywhere_by_data<TallyType: copy + drop + store> (
      poll: &Vote<TallyType>,
      tally_type: &TallyType,
    ): (bool, GUID::ID, u64, u8, bool)  {
     // looking in pending
     let (found, guid, idx) = find_index_of_ballot_by_data(poll, tally_type, PENDING);
     if (found) {
      let complete = is_completed(Vector::borrow(&poll.ballots_pending, idx));
       return (true, guid, idx, PENDING, complete)
     };

     // looking in approved
      let (found, guid, idx) = find_index_of_ballot_by_data(poll, tally_type, APPROVED);
      if (found) {
        let complete = is_completed(Vector::borrow(&poll.ballots_approved, idx));
        return (true, guid, idx, APPROVED, complete)
      };

     // looking in rejected
      let (found, guid, idx) = find_index_of_ballot_by_data(poll, tally_type, REJECTED);
      if (found) {
        let complete = is_completed(Vector::borrow(&poll.ballots_rejected, idx));
        return (true, guid, idx, REJECTED, complete)
      };

      (false, GUID::create_id(@0x0, 0), 0, 0, false)
    }

    public fun find_index_of_ballot<TallyType: copy + drop + store> (
      poll: &Vote<TallyType>,
      proposal_guid: &GUID::ID,
      status_enum: u8,
    ): (bool, u64) {

     let list = get_list_ballots_by_enum<TallyType>(poll, status_enum);

      let i = 0;
      while (i < Vector::length(list)) {
        let b = Vector::borrow(list, i);

        if (&GUID::id(&b.guid) == proposal_guid) {
          return (true, i)
        };
        i = i + 1;
      };

      (false, 0)
    }


    public fun find_index_of_ballot_by_data<TallyType: copy + drop + store> (
      poll: &Vote<TallyType>,
      tally_type: &TallyType,
      status_enum: u8,
    ): (bool, GUID::ID, u64) {

     let list = get_list_ballots_by_enum<TallyType>(poll, status_enum);

      let i = 0;
      while (i < Vector::length(list)) {
        let b = Vector::borrow(list, i);

        if (&b.tally_type == tally_type) {
          return (true, GUID::id(&b.guid), i)
        };
        i = i + 1;
      };

      (false, GUID::create_id(@0x0, 0), 0)
    }
    public fun get_list_ballots_by_enum<TallyType: copy + drop + store >(poll: &Vote<TallyType>, status_enum: u8): &vector<Ballot<TallyType>> {
     if (status_enum == PENDING) {
        &poll.ballots_pending
      } else if (status_enum == APPROVED) {
        &poll.ballots_approved
      } else if (status_enum == REJECTED) {
        &poll.ballots_rejected
      } else {
        assert!(false, Errors::invalid_argument(EBAD_STATUS_ENUM));
        & poll.ballots_rejected // dummy return
      }
    }

    public fun get_list_ballots_by_enum_mut<TallyType: copy + drop + store >(poll: &mut Vote<TallyType>, status_enum: u8): &mut vector<Ballot<TallyType>> {
     if (status_enum == PENDING) {
        &mut poll.ballots_pending
      } else if (status_enum == APPROVED) {
        &mut poll.ballots_approved
      } else if (status_enum == REJECTED) {
        &mut poll.ballots_rejected
      } else {
        assert!(false, Errors::invalid_argument(EBAD_STATUS_ENUM));
        &mut poll.ballots_rejected // dummy return
      }
    }

    public fun get_ballot_id<TallyType: copy + drop + store >(ballot: &Ballot<TallyType>): ID {
      return GUID::id(&ballot.guid)
    }


    public fun get_ballot_type<TallyType: copy + drop + store >(ballot: &Ballot<TallyType>): &TallyType {
      return &ballot.tally_type
    }

    public fun get_ballot_type_mut<TallyType: copy + drop + store >(ballot: &mut Ballot<TallyType>): &mut TallyType {
      return &mut ballot.tally_type
    }


    public fun is_completed<TallyType: copy + drop + store>(b: &Ballot<TallyType>):bool {
      b.completed
    }

    public fun complete_ballot<TallyType: copy + drop + store>(
      ballot: &mut Ballot<TallyType>,
    ) {
      ballot.completed = true;
    }

    /// Pop a ballot off a list and return it. This is owned not mutable.
    public fun extract_ballot<TallyType: copy + drop + store>(
      poll: &mut Vote<TallyType>,
      id: &GUID::ID,
      from_status_enum: u8,
    ): Ballot<TallyType>{
      let (found, idx) = find_index_of_ballot(poll, id, from_status_enum);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));
      let from_list = get_list_ballots_by_enum_mut<TallyType>(poll, from_status_enum);
      Vector::remove(from_list, idx)
    }

    /// extract a ballot and put on another list.
    public fun move_ballot<TallyType: copy + drop + store>(
      poll: &mut Vote<TallyType>,
      id: &GUID::ID,
      from_status_enum: u8,
      to_status_enum: u8,
    ) {
      let b = extract_ballot(poll, id, from_status_enum);
      let to_list = get_list_ballots_by_enum_mut<TallyType>(poll, to_status_enum);
      Vector::push_back(to_list, b);
    }


    /// third party contracts need to be able to access the data in the poll struct. But they are not able to borrow it.
    public fun get_tally_copy<TallyType: copy + drop + store>(
      poll: &mut Vote<TallyType>,
      id: &GUID::ID,
    ): TallyType {
      let (found, idx, status_enum, _completed) = find_anywhere(poll, id);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));
      let ballot = get_ballot_mut(poll, idx, status_enum);
      *&ballot.tally_type
    }

    //////// STANDALONE VOTE ////////
    /// Initialize poll struct which will be stored as-is on the account under Vote<Type>.
    /// Developers who need more flexibility, can instead construct the Vote object and then wrap it in another struct on their third party module.
    public fun standalone_init_poll_at_address<TallyType: copy + drop + store>(
      sig: &signer,
      poll: Vote<TallyType>,
    ) {
      move_to<Vote<TallyType>>(sig, poll)
    }

    /// If the Vote is standalone at root of address, you can use thie function as long as the CreateCapability is available.
    public fun standalone_propose_ballot<TallyType: copy + drop + store>(
      guid_cap: &GUID::CreateCapability,
      tally_type: TallyType,
    ) acquires Vote {
      let addr = GUID::get_capability_address(guid_cap);
      let poll = borrow_global_mut<Vote<TallyType>>(addr);
      propose_ballot(poll, guid_cap, tally_type);
    }

    public fun standalone_update_tally<TallyType: copy + drop + store> (
      guid_cap: &GUID::CreateCapability,
      uid: &GUID::ID,
      tally_type: TallyType,
    ) acquires Vote {
      let addr = GUID::get_capability_address(guid_cap);
      let poll = borrow_global_mut<Vote<TallyType>>(addr);
      let (found, idx, status_enum, _completed) = find_anywhere(poll, uid);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));
      let b = get_ballot_mut(poll, idx, status_enum);
      b.tally_type = tally_type;
    }

    /// tuple if the ballot is (found, its index, its status enum, is it completed)
    public fun standalone_find_anywhere<TallyType: copy + drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID): (bool, u64, u8, bool) acquires Vote {
      let vote_address = GUID::get_capability_address(guid_cap);
      let poll = borrow_global_mut<Vote<TallyType>>(vote_address);
      find_anywhere(poll, uid)
    }

    public fun standalone_get_tally_copy<TallyType: copy + drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID): TallyType acquires Vote {
      let vote_address = GUID::get_capability_address(guid_cap);
      let poll = borrow_global_mut<Vote<TallyType>>(vote_address);
      get_tally_copy(poll, uid)
    }

    public fun standalone_complete_and_move<TallyType: copy + drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID, to_status_enum: u8) acquires Vote {
      let vote_address = GUID::get_capability_address(guid_cap);
      let poll = borrow_global_mut<Vote<TallyType>>(vote_address);
      
      let (found, idx, from_status_enum, _completed) = find_anywhere(poll, uid);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      let b = get_ballot_mut(poll, idx, from_status_enum);
      complete_ballot(b);
      move_ballot(poll, uid, from_status_enum, to_status_enum);

    }

  }

  /// This is an example of how to use VoteLib, to create a standalone poll.
  /// In this example we are making a naive DAO payment approval system.
  /// whenever the deadline passes, the next vote will trigger a tally
  /// and if the tally is successful, the payment will be made.
  /// If the tally is not successful, the payment will be rejected.
  module ExampleStandalonePoll {

    use DiemFramework::VoteLib;
    use Std::GUID;
    use Std::Vector;
    use Std::Signer;
    use Std::Errors;
    use Std::Option::{Self, Option};
    use DiemFramework::DiemConfig;

    const EINVALID_VOTE: u64 = 0;

    struct DummyTally has store, drop, copy {}

    /// a tally can have any kind of data to support the vote.
    /// this is an example of a binary count.
    /// A dev should also insert data into the tally, to be used in an
    /// action that is triggered on completion.
    struct UsefulTally<IssueData> has store, drop, copy {
      votes_for: u64,
      votes_against: u64,
      voters: vector<address>, // this is a list of voters who have voted. You may prefer to move the voted flag to the end user's address (or do a bloom filter).
      deadline_epoch: u64,
      tally_result: Option<bool>,
      issue_data: IssueData,
    }

    /// a tally can have some arbitrary data payload.
    struct ExampleIssueData has store, drop, copy {
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

    /// The signer can always access a new GUID::CreateCapability
    /// On a multisig type account, will need to store the CreateCapability 
    /// wherever the multisig authorities can access it. Be careful ou there!
    public fun init_empty_tally(sig: &signer) {
      let poll = VoteLib::new_poll<DummyTally>();


      let guid_cap = GUID::gen_create_capability(sig);

      VoteLib::standalone_init_poll_at_address<DummyTally>(sig, poll);

      VoteLib::standalone_propose_ballot<DummyTally>(&guid_cap, DummyTally {})

    }


    public fun init_useful_tally(sig: &signer) {
      let poll = VoteLib::new_poll<UsefulTally<ExampleIssueData>>();


      let guid_cap = GUID::gen_create_capability(sig);

      VoteLib::standalone_init_poll_at_address<UsefulTally<ExampleIssueData>>(sig, poll);

      let t = UsefulTally {
        votes_for: 0,
        votes_against: 0,
        voters: Vector::empty(),
        deadline_epoch: DiemConfig::get_current_epoch() + 7,
        tally_result: Option::none<bool>(),
        issue_data: ExampleIssueData {
          pay_this_person: @0xDEADBEEF,
          amount: 0,
          description: b"hello world",
        }
      };

      VoteLib::standalone_propose_ballot<UsefulTally<ExampleIssueData>>(&guid_cap, t);

      // store the capability in the account so it can be used later by someone other than the owner of the account. (e.g. a voter.)
      move_to(sig, VoteCapability { guid_cap });
    }

    // The voting handlers are defined by the thrid party module NOT the VoteLib module. The VoteLib module only provides the APIs to move proposals from one list to another. The external contract needs to decide how that should happen.

    public fun vote(sig: &signer, vote_address: address, id: &GUID::ID, vote_for: bool) acquires VoteCapability {

      // get the GUID capability stored here
      let cap = &borrow_global<VoteCapability>(vote_address).guid_cap;

      let (found, _idx, status_enum, is_completed) = VoteLib::standalone_find_anywhere<UsefulTally<ExampleIssueData>>(cap, id);

      assert!(found, Errors::invalid_argument(EINVALID_VOTE));
      assert!(!is_completed, Errors::invalid_argument(EINVALID_VOTE));
      // is a pending ballot
      assert!(status_enum == 0, Errors::invalid_argument(EINVALID_VOTE));



      // check signer did not already vote
      let t = VoteLib::standalone_get_tally_copy<UsefulTally<ExampleIssueData>>(cap, id);

      // check if the signer has already voted
      let signer_addr = Signer::address_of(sig);
      let found = Vector::contains(&t.voters, &signer_addr);
      assert!(!found, Errors::invalid_argument(0));

      if (vote_for) {
        t.votes_for = t.votes_for + 1;
      } else {
        t.votes_against = t.votes_against + 1;
      };


      // add the signer to the list of voters
      Vector::push_back(&mut t.voters, signer_addr);
      

      // update the tally

      maybe_tally(&mut t);

      // update the ballot
      VoteLib::standalone_update_tally<UsefulTally<ExampleIssueData>>(cap, id,  copy t);


      if (Option::is_some(&t.tally_result)) {
        let passed = *Option::borrow(&t.tally_result);
        let status_enum = if (passed) {
          // run the payment handler
          payment_handler(&t);
          1 // approved
        } else {
          
          2 // rejected
        };
        // since we have a result lets update the VoteLib state
        VoteLib::standalone_complete_and_move<UsefulTally<ExampleIssueData>>(cap, id, status_enum);

      }

      


    }

    fun payment_handler(t: &UsefulTally<ExampleIssueData>) {
        
          // do the action
          // pay the person

                
        let _payee = t.issue_data.pay_this_person;
        let _amount = t.issue_data.amount;
        let _description = *&t.issue_data.description;
        // MAKE THE PAYMENT.
    }

    fun maybe_tally(t: &mut UsefulTally<ExampleIssueData>): Option<bool> {
      // check if the tally is complete
      // if so, move the tally to the completed list
      // if not, do nothing

      if (DiemConfig::get_current_epoch() > t.deadline_epoch) {
        // tally is complete
        // move the tally to the completed list
        // call the action
        if (t.votes_for > t.votes_against) {
          t.tally_result = Option::some(true);
        } else {
          t.tally_result = Option::some(false);
        }

      };

      *&t.tally_result

    }

  }
}