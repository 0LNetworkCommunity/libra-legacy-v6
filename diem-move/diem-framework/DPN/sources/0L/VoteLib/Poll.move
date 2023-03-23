
address DiemFramework {
    module Poll {
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
    // Developers can use Poll struct to instantiate an election.
    // or then can use Ballot, for a custom voting solution.
    // lastly the developer can simply wrap refereundum into another struct with more context.

    struct Poll<IssueData, TallyType> has key, store, drop {
      ballots_pending: vector<Ballot<IssueData, TallyType>>,
      ballots_approved: vector<Ballot<IssueData, TallyType>>,
      ballots_rejected: vector<Ballot<IssueData, TallyType>>,
    }

    struct Ballot<IssueData, TallyType> has key, store, drop {
      guid: GUID::GUID,
      issue: IssueData, // issue is the data of what is being decided.
      tally_type: TallyType, // a tally type includes how the count happens and the deadline.
      completed: bool,
    }


    public fun new_poll<
      IssueData: copy + drop + store,
      TallyType: copy + drop + store
    >(): Poll<IssueData, TallyType> {
      Poll {
        ballots_pending: Vector::empty(),
        ballots_approved: Vector::empty(),
        ballots_rejected: Vector::empty(),
      }
    }

    public fun propose_ballot<
      IssueData: copy + drop + store,
      TallyType: copy + drop + store
    >(
      poll: &mut Poll<IssueData, TallyType>,
      guid_cap: &GUID::CreateCapability, // whoever is ceating this issue needs access to the GUID creation capability
      issue: IssueData,
      tally_type: TallyType,
    ): &mut Ballot<IssueData, TallyType>  {
      let b = Ballot {

        guid: GUID::create_with_capability(@0xDEADBEEF, guid_cap), // address is ignored.
        issue,
        tally_type,
        completed: false,
       
      };
      let len = Vector::length(&poll.ballots_pending);
      Vector::push_back(&mut poll.ballots_pending, b);
      Vector::borrow_mut(&mut poll.ballots_pending, len + 1)
    }

    /// private function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.
    public fun get_ballot_mut<
      IssueData: copy + drop + store,
      TallyType: copy + drop + store,
    > (
      poll: &mut Poll<IssueData, TallyType>,
      idx: u64, 
      status_enum: u8
    ): &mut Ballot<IssueData, TallyType> {

      let list = get_list_ballots_by_enum<IssueData, TallyType>(poll, status_enum);

      assert!(Vector::length(list) > idx, Errors::invalid_argument(ENO_BALLOT_FOUND));

      Vector::borrow_mut(list, idx)
    }

    public fun find_index_of_ballot<
      IssueData: copy + drop + store,
      TallyType: copy + drop + store,
    > (
      poll: &mut Poll<IssueData, TallyType>,
      proposal_guid: &GUID::ID,
      status_enum: u8
    ): (bool, u64) {

     let list = get_list_ballots_by_enum<IssueData, TallyType>(poll, status_enum);

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

    public fun get_list_ballots_by_enum<
      IssueData: copy + drop + store,
      TallyType: copy + drop + store,
    >(poll: &mut Poll<IssueData, TallyType>, status_enum: u8): &mut vector<Ballot<IssueData, TallyType>> {
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

    public fun get_ballot_id<
      IssueData: copy + drop + store,
      TallyType: copy + drop + store,
    >(ballot: &Ballot<IssueData, TallyType>): ID {
      return GUID::id(&ballot.guid)
    }

  }
}