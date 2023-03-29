
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

    struct Vote<TallyType> has store, drop { // Vote cannot be stored in global storage, and cannot be copied
      ballots_pending: vector<Ballot<TallyType>>,
      ballots_approved: vector<Ballot<TallyType>>,
      ballots_rejected: vector<Ballot<TallyType>>,
    }

    struct Ballot<TallyType> has store, drop { // ballots cannot be stored in global storage and cannot be copied
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
    public fun new_poll<TallyType: drop + store>(): Vote<TallyType> {
      Vote {
        ballots_pending: Vector::empty(),
        ballots_approved: Vector::empty(),
        ballots_rejected: Vector::empty(),
      }
    }

    /// If you have a mutable Vote instance AND you have the GUID Create Capability, you can use this to create a ballot.
    public fun propose_ballot<TallyType:  drop + store>(
      poll: &mut Vote<TallyType>,
      guid_cap: &GUID::CreateCapability, // whoever is ceating this issue needs access to the GUID creation capability
      // issue: IssueData,
      tally_type: TallyType,
    ): &mut Ballot<TallyType>  {
      let ignored_addr = GUID::get_capability_address(guid_cap); // Note 0L's modification to Std::GUID, to get_capability_address

      let b = Ballot {

        guid: GUID::create_with_capability(ignored_addr, guid_cap), // Note 0L's modification to Std::GUID, address is ignored.
        // issue,
        tally_type,
        completed: false,
       
      };
      let len = Vector::length(&poll.ballots_pending);
      Vector::push_back(&mut poll.ballots_pending, b);
      Vector::borrow_mut(&mut poll.ballots_pending, len + 1)
    }


    // with only a GUID, return a ballot mutable
    public fun get_ballot_by_id<TallyType: drop + store> (
      poll: & Vote<TallyType>,
      guid: &GUID::ID,
    ): &Ballot<TallyType> {

      let (found, idx, status_enum, _completed) = find_anywhere(poll, guid);

      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      get_ballot<TallyType>(poll, idx, status_enum)
    }


    // with only a GUID, return a ballot mutable
    public fun get_ballot_by_id_mut<TallyType: drop + store> (
      poll: &mut Vote<TallyType>,
      guid: &GUID::ID,
    ): &mut Ballot<TallyType> {

      let (found, idx, status_enum, _completed) = find_anywhere(poll, guid);

      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      get_ballot_mut<TallyType>(poll, idx, status_enum)
    }


    /// function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.
    public fun get_ballot_mut<TallyType: drop + store> (
      poll: &mut Vote<TallyType>,
      idx: u64, 
      status_enum: u8
    ): &mut Ballot<TallyType> {

      let list = get_list_ballots_by_enum_mut<TallyType>(poll, status_enum);

      assert!(Vector::length(list) > idx, Errors::invalid_argument(ENO_BALLOT_FOUND));

      Vector::borrow_mut(list, idx)
    }


    /// function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.
    public fun get_ballot<TallyType: drop + store> (
      poll: &Vote<TallyType>,
      idx: u64, 
      status_enum: u8
    ): &Ballot<TallyType> {

      let list = get_list_ballots_by_enum<TallyType>(poll, status_enum);

      assert!(Vector::length(list) > idx, Errors::invalid_argument(ENO_BALLOT_FOUND));

      Vector::borrow(list, idx)
    }


    /// find the ballot wherever it is: pending, approved, rejected.
    /// returns a tuple of (is_found: bool, index: u64, status_enum: u8, is_complete: bool)
    public fun find_anywhere<TallyType: drop + store> (
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
    public fun find_anywhere_by_data<TallyType: drop + store> (
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

    public fun find_index_of_ballot<TallyType: drop + store> (
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


    public fun find_index_of_ballot_by_data<TallyType: drop + store> (
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
    public fun get_list_ballots_by_enum<TallyType: drop + store >(poll: &Vote<TallyType>, status_enum: u8): &vector<Ballot<TallyType>> {
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

    public fun get_list_ballots_by_enum_mut<TallyType: drop + store >(poll: &mut Vote<TallyType>, status_enum: u8): &mut vector<Ballot<TallyType>> {
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

    public fun get_ballot_id<TallyType: drop + store >(ballot: &Ballot<TallyType>): ID {
      return GUID::id(&ballot.guid)
    }


    public fun get_ballot_type<TallyType: drop + store >(ballot: &Ballot<TallyType>): &TallyType {
      return &ballot.tally_type
    }

    public fun get_ballot_type_mut<TallyType: drop + store >(ballot: &mut Ballot<TallyType>): &mut TallyType {
      return &mut ballot.tally_type
    }

    // Overwrites the ballot data. This is a convenience function, so that you may not need to update each field in the struct. Use with caution.
    public fun set_ballot_data<TallyType: drop + store >(ballot: &mut Ballot<TallyType>, t: TallyType) {
      // Devs: FYI need to do this internal to the module that owns Ballot
      // you won't be able to do this from outside the module
      ballot.tally_type = t;
    }


    public fun is_completed<TallyType: drop + store>(b: &Ballot<TallyType>):bool {
      b.completed
    }

    public fun complete_ballot<TallyType: drop + store>(
      ballot: &mut Ballot<TallyType>,
    ) {
      ballot.completed = true;
    }

    /// Pop a ballot off a list and return it. This is owned not mutable.
    public fun extract_ballot<TallyType: drop + store>(
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
    public fun move_ballot<TallyType: drop + store>(
      poll: &mut Vote<TallyType>,
      id: &GUID::ID,
      from_status_enum: u8,
      to_status_enum: u8,
    ) {
      let b = extract_ballot(poll, id, from_status_enum);
      let to_list = get_list_ballots_by_enum_mut<TallyType>(poll, to_status_enum);
      Vector::push_back(to_list, b);
    }
     // /// third party contracts need to be able to access the data in the poll struct. But they are not able to borrow it.
    // public fun get_tally_copy<TallyType: drop + store>(
    //   poll: &mut Vote<TallyType>,
    //   id: &GUID::ID,
    // ): TallyType {
    //   let (found, idx, status_enum, _completed) = find_anywhere(poll, id);
    //   assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));
    //   let ballot = get_ballot_mut(poll, idx, status_enum);
    //   *&ballot.tally_type
    // }



  }

}