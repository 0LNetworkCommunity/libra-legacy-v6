
address DiemFramework {

      /// VoteLib is a primitive for creating Ballots, keeping track of them.
      /// This library does not keep or manage any state. The BallotTracker and Ballots will be stored in your external contract.
      /// It's meant to be generic, so you can use it for any kind of voting system, and even multisig type use cases.
      /// There are examples on how to do this in BinaryBallot, and MultiSig.
      /// All methods are restricted by the ability to aquire the BallotTracker and Ballots, and also the Owner's GUID CreateCapability (which can be moved into a struct so that it can be accessed programatically outside of owner transactions, see MultiSig as an example).
      /// The actual logic of what happens when a ballot passes, exists outside of this module. That is, there are no "tally" methods here. 
      /// There are no handlers here either, your library needs to handle the result of a transaction and a vote outcome.

      /// Developers may simply initialize a poll struct at the root level of their address, and include a field for BallotTracker (see BinaryBallot as an example).
      
      /// Design:
      /// VoteLib is only opinionated as to the possible status of Ballots: Pending, Approved, Rejected. 

      /// Every Ballot has a minimalist set fields properties: GUID and whether it is completed. 
      // What is powerful (and initially confusing) is that every Ballot has also has a storage field for a generic. So you can pass specific TallyType data into the Ballot.
      /// Examples of data include: what fields do you need for polling? Is is a simple counter of approve, reject, or do we need more fields (like a vector of addresses that voted yes). This library is unopinionated.

      /// In that generic for TallyType, one can also nest a separate Struct with, and so on, like russian dolls. But in practice inside a TallyType you may want to add data for this ballots "issue" at hand, so that it can be programattically accessed by a handler. I.e. in a multisig case: You can have TallyType<PaymentInstruction> { addresses_in_favor: vector<address>, issue: PaymentInstruction }. Which in itself is PaymentInstruction { amount: u64, payee: address }.

      /// Note to devs new to Move. Because of how Move language works, you are not able to mutate the Ballot type in a third party module. But there isn't much to do on it anyway, only mark it "completed". And there is a method for that.
      /// What you may initially struggle with is the TallyType cannot be modified in this library, it must be mutated in the Library that defines your TallyType (see BinaryBallot). So you should borrow a mutable reference of the TallyType with get_type_struct_mut(), and then mutate it in your contract.

    module Ballot {
    use Std::Vector;
    use Std::GUID::{Self, ID};
    use Std::Errors;

    /// No ballot found under that GUID
    const ENO_BALLOT_FOUND: u64 = 300010;
    /// Bad status enum
    const EBAD_STATUS_ENUM: u64 = 300011;


    // poor man's enum for the ballot status. Wen enum?
    const PENDING: u8  = 1;
    const APPROVED: u8 = 2;
    const REJECTED: u8 = 3;
    
    public fun get_pending_enum(): u8 {
      PENDING
    }
    public fun get_approved_enum(): u8 {
      APPROVED
    }
    public fun get_rejected_enum(): u8 {
      REJECTED
    }


    struct Ballot<TallyType> has store, drop { // ballots cannot be stored in global storage and cannot be copied
      guid: GUID::GUID,
      // issue: IssueData, // issue is the data of what is being decided.
      tally_type: TallyType, // a tally type includes how the count happens and the deadline.
      completed: bool,
    }

    struct BallotTracker<TallyType> has store, drop { // BallotTracker cannot be stored in global storage, and cannot be copied
      ballots_pending: vector<Ballot<TallyType>>,
      ballots_approved: vector<Ballot<TallyType>>,
      ballots_rejected: vector<Ballot<TallyType>>,
    }

    ////////  CONSTRUCTORS ////////

    /// The poll constructor. Use this to create the tracker for each (generic) TallyType that you are instantiating. You may have multiple polls, each with a different TallyType tracker.
    // E.g. `struct Mystruct<TallyType> has key { poll: BallotTracker<TallyType> }`
    public fun new_tracker<TallyType: drop + store>(): BallotTracker<TallyType> {
      BallotTracker {
        ballots_pending: Vector::empty(),
        ballots_approved: Vector::empty(),
        ballots_rejected: Vector::empty(),
      }
    }

    /// If you have a mutable BallotTracker instance AND you have the GUID Create Capability, you can use this to create a ballot.
    public fun propose_ballot<TallyType:  drop + store>(
      tracker: &mut BallotTracker<TallyType>,
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
      let len = Vector::length(&tracker.ballots_pending);
      Vector::push_back(&mut tracker.ballots_pending, b);
      Vector::borrow_mut(&mut tracker.ballots_pending, len)
    }


    ////////  GETTERS ////////

    public fun is_completed<TallyType: drop + store>(b: &Ballot<TallyType>):bool {
      b.completed
    }
    // with only a GUID, return a ballot reference
    public fun get_ballot_by_id<TallyType: drop + store> (
      poll: & BallotTracker<TallyType>,
      guid: &GUID::ID,
    ): &Ballot<TallyType> {

      let (found, idx, status_enum, _completed) = find_anywhere(poll, guid);

      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      get_ballot<TallyType>(poll, idx, status_enum)
    }


    // with only a GUID, return a ballot mutable
    public fun get_ballot_by_id_mut<TallyType: drop + store> (
      poll: &mut BallotTracker<TallyType>,
      guid: &GUID::ID,
    ): &mut Ballot<TallyType> {

      let (found, idx, status_enum, _completed) = find_anywhere(poll, guid);

      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      get_ballot_mut<TallyType>(poll, idx, status_enum)
    }

    /// function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.
    public fun get_ballot<TallyType: drop + store> (
      poll: &BallotTracker<TallyType>,
      idx: u64, 
      status_enum: u8
    ): &Ballot<TallyType> {

      let list = get_list_ballots_by_enum<TallyType>(poll, status_enum);

      assert!(Vector::length(list) > idx, Errors::invalid_argument(ENO_BALLOT_FOUND));

      Vector::borrow(list, idx)
    }

    /// function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.
    public fun get_ballot_mut<TallyType: drop + store> (
      poll: &mut BallotTracker<TallyType>,
      idx: u64, 
      status_enum: u8
    ): &mut Ballot<TallyType> {

      let list = get_list_ballots_by_enum_mut<TallyType>(poll, status_enum);

      assert!(Vector::length(list) > idx, Errors::invalid_argument(ENO_BALLOT_FOUND));

      Vector::borrow_mut(list, idx)
    }


    /// For fetching the underlying TallyType struct (which is defined in your third party module)
    public fun get_type_struct<TallyType: drop + store >(ballot: &Ballot<TallyType>): &TallyType {
      return &ballot.tally_type
    }

    public fun get_type_struct_mut<TallyType: drop + store >(ballot: &mut Ballot<TallyType>): &mut TallyType {
      return &mut ballot.tally_type
    }


    ////////  SEARCH ////////

    /// find the ballot wherever it is: pending, approved, rejected.
    /// returns a tuple of (is_found: bool, index: u64, status_enum: u8, is_complete: bool)
    public fun find_anywhere<TallyType: drop + store> (
      tracker: &BallotTracker<TallyType>,
      proposal_guid: &GUID::ID,
    ): (bool, u64, u8, bool) {

     // looking in pending
     let (found, idx) = find_index_of_ballot(tracker, proposal_guid, PENDING);
     if (found) {
      let complete = is_completed(Vector::borrow(&tracker.ballots_pending, idx));
       return (true, idx, PENDING, complete)
     };

     // looking in approved
      let (found, idx) = find_index_of_ballot(tracker, proposal_guid, APPROVED);
      if (found) {
        let complete = is_completed(Vector::borrow(&tracker.ballots_approved, idx));
        return (true, idx, APPROVED, complete)
      };

     // looking in rejected
      let (found, idx) = find_index_of_ballot(tracker, proposal_guid, REJECTED);
      if (found) {
        let complete = is_completed(Vector::borrow(&tracker.ballots_rejected, idx));
        return (true, idx, REJECTED, complete)
      };

      (false, 0, 0, false)
    }

    /// find the index in list, if you know the GUID.
    /// If you need to search for the GUID by data, Ballot cannot do that.
    /// since you may need to look at specific fields to find duplications
    /// you'll need to do the search wherever TallyType is defined.
    /// For example: if we tried to do it here, and there was a field of `voted` addresses, you would never find a duplicate.
    public fun find_index_of_ballot<TallyType: drop + store> (
      tracker: &BallotTracker<TallyType>,
      proposal_guid: &GUID::ID,
      status_enum: u8,
    ): (bool, u64) {

     let list = get_list_ballots_by_enum<TallyType>(tracker, status_enum);

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

    public fun get_list_ballots_by_enum<TallyType: drop + store >(tracker: &BallotTracker<TallyType>, status_enum: u8): &vector<Ballot<TallyType>> {
     if (status_enum == PENDING) {
        &tracker.ballots_pending
      } else if (status_enum == APPROVED) {
        &tracker.ballots_approved
      } else if (status_enum == REJECTED) {
        &tracker.ballots_rejected
      } else {
        assert!(false, Errors::invalid_argument(EBAD_STATUS_ENUM));
        & tracker.ballots_rejected // dummy return
      }
    }

    public fun get_list_ballots_by_enum_mut<TallyType: drop + store >(tracker: &mut BallotTracker<TallyType>, status_enum: u8): &mut vector<Ballot<TallyType>> {
     if (status_enum == PENDING) {
        &mut tracker.ballots_pending
      } else if (status_enum == APPROVED) {
        &mut tracker.ballots_approved
      } else if (status_enum == REJECTED) {
        &mut tracker.ballots_rejected
      } else {
        assert!(false, Errors::invalid_argument(EBAD_STATUS_ENUM));
        &mut tracker.ballots_rejected // dummy return
      }
    }

    public fun get_ballot_id<TallyType: drop + store >(ballot: &Ballot<TallyType>): ID {
      return GUID::id(&ballot.guid)
    }

    //////// WRITE ////////

    // Overwrites the ballot data. This is a convenience function, so that you may not need to update each field in the struct. Use with caution.
    public fun set_ballot_data<TallyType: drop + store >(ballot: &mut Ballot<TallyType>, t: TallyType) {
      // Devs: FYI need to do this internal to the module that owns Ballot
      // you won't be able to do this from outside the module
      ballot.tally_type = t;
    }

    public fun complete_ballot<TallyType: drop + store>(
      ballot: &mut Ballot<TallyType>,
    ) {
      ballot.completed = true;
    }

    /// Pop a ballot off a list and return it. This is owned not mutable.
    public fun extract_ballot<TallyType: drop + store>(
      tracker: &mut BallotTracker<TallyType>,
      id: &GUID::ID,
      from_status_enum: u8,
    ): Ballot<TallyType>{
      let (found, idx) = find_index_of_ballot(tracker, id, from_status_enum);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));
      let from_list = get_list_ballots_by_enum_mut<TallyType>(tracker, from_status_enum);
      Vector::remove(from_list, idx)
    }

    /// extract a ballot and put on another list.
    public fun move_ballot<TallyType: drop + store>(
      tracker: &mut BallotTracker<TallyType>,
      id: &GUID::ID,
      from_status_enum: u8,
      to_status_enum: u8,
    ) {
      let b = extract_ballot(tracker, id, from_status_enum);
      let to_list = get_list_ballots_by_enum_mut<TallyType>(tracker, to_status_enum);
      Vector::push_back(to_list, b);
    }

  }
}