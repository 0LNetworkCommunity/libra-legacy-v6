///////////////////////////////////////////////////////////////////////////
// 0L Module
// VoteLib
// Intatiate different types of user-interactive voting
///////////////////////////////////////////////////////////////////////////

// TODO: Move this to a separate address. Potentially has separate governance.
address DiemFramework { 

  module ParticipationVote {

    // ParticipationVote is a single issue referendum, with only votes in favor or against.
    // The design of the policies attempts to accomodate online voting where votes tend to happen:
    // 1. publicly
    // 2. asynchronously
    // 3. with a low turnout
    // 4. of voters with high conviction

    // Low turnouts are not indicative of disinterest (often termed voter apathy), but instead it is just "rational ignorance" of the matters being voted. Adaptive deadlines and thresholds are an attempt to encourage more familiarity with the matters, and thus more participation. At the same time it allows for consensus decisions to be reached in a timely manner by the active and interested participants.

    // The ballots have dynamic deadlines and thresholds.
    // deadlines can be extended by dissenting votes from the current majority vote. This cannot be done indefinitely, as the extension is capped by the max_deadline.
    // The threshold (percent approval/rejection which needs to be met) is determined post-hoc. Referenda are expensive, for communities, leaders, and voters. Instead of scapping a vote which doesn't achieve a pre-established number of participants (quorum), the vote is allowed to be tallied and be seen as valid. However, the threshold must be higher (more than 51%) in cases where the turnout is low. In blockchain polkadot network has prior art for this: https://wiki.polkadot.network/docs/en/learn-governance#adaptive-quorum-biasing
    // In Polkadot implementation there are positive and negative biasing. Negative biasing (when turnout is low, a lower amount of votes is needed) seems to be an edge case.

    // Regarding deadlines. The problem with adaptive thresholds is that it favors the engaged community. If you are unaware of the process, or if the process occurred silently, it's very challenging to swing the vote. So the minority vote may be disadvantaged due to lack of engagement, and there should be some accomodation. If they are coming late to the vote, AND in significant numbers, then they can get an extension. The initial design aims to allow an extension if on the day the poll closes, a sufficient amount of the vote was shifted in the minority direction, an extra day is added. This will happen for each new deadline.

    // THE BALLOT
    // Ballot is a single proposal that can be voted on.
    // Each ballot will run for the minimum period of time.
    // The deadline can be extended with dissenting votes from the current majority vote.
    // The turnout can be extended with dissenting votes from the current majority vote.
    // the threshold is dictated by the turnout. In this implementation the curve is fixed, and linear.
    // At 1/8th turnout, the threshold to be met is 100%
    // At 7/8th turnout, the threshold to be met is 51%

    use Std::FixedPoint32;
    use Std::Vector;
    use Std::Signer;
    use Std::GUID::{Self, GUID, ID};
    use Std::Errors;
    use DiemFramework::DiemConfig;

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

    /// for voting to happen with the VoteLib module, the GUID creation capability must be passed in, and so the signer for the addres (the "sponsor" of the ballot) must move the capability to be accessible by the contract logic.

    struct VoteCapability has key {
      guid_cap: GUID::CreateCapability,
    }
    
    struct Poll<Data> has key, store, drop {
      ballots_pending: vector<Ballot<Data>>,
      ballots_approved: vector<Ballot<Data>>,
      ballots_rejected: vector<Ballot<Data>>,
    }

    public fun new_poll<Data: copy + store>(): Poll<Data> {
      Poll {
        ballots_pending: Vector::empty(),
        ballots_approved: Vector::empty(),
        ballots_rejected: Vector::empty(),
      }
    }

    public fun propose_ballot<Data: copy + store>(
      guid_cap: &GUID::CreateCapability,
      poll: &mut Poll<Data>,
      data: Data,
      max_vote_enrollment: u64,
      deadline: u64,
      max_extensions: u64,
    ): &mut Ballot<Data> {
      let ballot = new_ballot(guid_cap, data, max_vote_enrollment, deadline, max_extensions);
      let len = Vector::length(&poll.ballots_pending);
      Vector::push_back(&mut poll.ballots_pending, ballot);
      Vector::borrow_mut(&mut poll.ballots_pending, len + 1)
    }
    /// private function to search in the ballots for an existsing veto. Returns and option type with the Ballot id.
    public fun get_ballot_mut<Data: copy + store> (poll: &mut Poll<Data>, proposal_guid: &GUID::ID, status_enum: u8): &mut Ballot<Data> {
      
      let (found, idx) = find_index_of_ballot(poll, proposal_guid, status_enum);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

      let list = get_list_ballots_by_enum<Data>(poll, status_enum);

      Vector::borrow_mut(list, idx)
    }

    fun find_index_of_ballot<Data: copy + store>(poll: &mut Poll<Data>, proposal_guid: &GUID::ID, status_enum: u8): (bool, u64) {

     let list = get_list_ballots_by_enum<Data>(poll, status_enum);

      let i = 0;
      while (i < Vector::length(list)) {
        let b = Vector::borrow(list, i);
        if (&get_ballot_id(b) == proposal_guid) {
          return (true, i)
        };
        i = i + 1;
      };

      (false, 0)
    }

    fun get_list_ballots_by_enum<Data: copy + store>(poll: &mut Poll<Data>, status_enum: u8): &mut vector<Ballot<Data>> {
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


    struct Ballot<Data> has key, store, drop { // Note, this is a hot potato. Any methods chaning it must return the struct to caller.
      guid: GUID,
      data: Data, // TODO: change to ascii string
      cfg_deadline: u64, // original deadline, which may be extended. Note dedaline is at the END of this epoch (cfg_deadline + 1 stops taking votes)
      cfg_max_extensions: u64, // if 0 then no max. Election can run until threshold is met.
      cfg_min_turnout: u64,
      cfg_minority_extension: bool,
      completed: bool,
      max_votes: u64, // what's the entire universe of votes. i.e. 100% turnout
      // vote_tickets: VoteTicket, // the tickets that can be used to vote, which will be deducted as votes are cast. It is initialized with the max_votes.
      // Note the developer needs to be aware that if the right to vote changes throughout the period of the election (more coins, participants etc) then the max_votes and tickets could skew from expected results. Vote tickets can be distributed in advance.
      votes_approve: u64, // the running tally of approving votes,
      votes_reject: u64, // the running tally of rejecting votes,
      extended_deadline: u64, // which epoch was the deadline extended to
      last_epoch_voted: u64, // the last epoch which received a vote
      last_epoch_approve: u64, // what was the approval percentage at the last epoch. For purposes of calculating extensions.
      last_epoch_reject: u64, // what was the rejection percentage at the last epoch. For purposes of calculating extensions.
      provisional_pass_epoch: u64, // once a threshold is met, mark that epoch, a further vote on the next epoch will seal the election, to give time for the minority to vote.
      tally_approve: u64,  // use two decimal places 1234 = 12.34%
      tally_turnout: u64, // use two decimal places 1234 = 12.34%
      tally_pass: bool, // if it passed
    }

    struct VoteReceipt has key, store, drop, copy { 
      guid: GUID::ID,
      approve_reject: bool,
      weight: u64,
    }
    struct IVoted has key {
      elections: vector<VoteReceipt>,
    }

    public fun new_ballot<Data: copy + store>(
      guid_cap: &GUID::CreateCapability,
      data: Data,
      max_vote_enrollment: u64,
      deadline: u64,
      max_extensions: u64,
    ): Ballot<Data> {
        Ballot<Data> {
          guid: GUID::create_with_capability(GUID::get_capability_address(guid_cap), guid_cap),
          data,
          cfg_deadline: deadline,
          cfg_max_extensions: max_extensions, // 0 means infinite extensions
          cfg_min_turnout: 1250,
          cfg_minority_extension: true,
          completed: false,
          max_votes: max_vote_enrollment,
          votes_approve: 0,
          votes_reject: 0,
          extended_deadline: deadline,
          last_epoch_voted: 0,
          last_epoch_approve: 0,
          last_epoch_reject: 0,
          provisional_pass_epoch: 0,
          tally_approve: 0,
          tally_turnout: 0,
          tally_pass: false,
        }
    }

    // Only the contract, which is the keeper of the Ballot, can allow a user to temporarily hold the Ballot struct to update the vote. The user cannot arbiltrarily update the vote, with an arbitrary number of votes.
    // This is a hot potato, it cannot be dropped.

    // the vote flow will return if the ballot passed (on the vote that gets over the threshold). This can be used for triggering actions lazily.

    public fun vote<Data: copy + store>(ballot: &mut Ballot<Data>, user: &signer, approve_reject: bool, weight: u64): bool acquires IVoted {
      // voting should not be complete
      assert!(!is_complete(ballot), Errors::invalid_state(ECOMPLETED));

      // check if this person voted already.
      // If the vote is the same directionally (approve, reject), exit early.
      // otherwise, need to subtract the old vote and add the new vote.
      let user_addr = Signer::address_of(user);
      let (_, is_found) = find_prior_vote_idx(user_addr, &GUID::id(&ballot.guid));

      assert!(!is_found, Errors::invalid_state(EALREADY_VOTED));

      // if we are in a new epoch than the previous last voter, then store that epoch data.
      let epoch_now = DiemConfig::get_current_epoch();
      if (epoch_now > ballot.last_epoch_voted) {
        ballot.last_epoch_approve = ballot.votes_approve;
        ballot.last_epoch_reject = ballot.votes_reject;
      };

      // in every case, add the new vote
      ballot.last_epoch_voted = epoch_now;
      if (approve_reject) {
        ballot.votes_approve = ballot.votes_approve + weight;
      } else {
        ballot.votes_reject = ballot.votes_reject + weight;
      };

      // always tally on each vote
      // make sure all extensions happened in previous step.
      maybe_tally(ballot);

      // this will handle the case of updating the receipt in case this is a second vote.
      make_receipt(user, &GUID::id(&ballot.guid), approve_reject, weight);

      ballot.tally_pass // return if it passed, so it can be used in a third party contract handler for lazy evaluation.
    }

    fun is_complete<Data: copy + store>(ballot: &mut Ballot<Data>): bool {
      let epoch = DiemConfig::get_current_epoch();
      // if completed, exit early
      if (ballot.completed) { return true }; // this should be checked above anyways.

      // this may be a vote that never expires, until a decision is reached
      if (ballot.cfg_deadline == 0 ) { return false };

      // if original and extended deadline have passed, stop tally
      // while we are here, update to "completed".
      if (
        epoch > ballot.cfg_deadline &&
        epoch > ballot.extended_deadline
      ) { 
        ballot.completed = true;
        return true
      };
      ballot.completed
    }

    public fun retract<Data: copy + store>(ballot: &mut Ballot<Data>, user: &signer) acquires IVoted {
      let user_addr = Signer::address_of(user);

      let (idx, is_found) = find_prior_vote_idx(user_addr, &GUID::id(&ballot.guid));
      assert!(is_found, Errors::invalid_state(ENOT_VOTED));

      let (approve_reject, weight) = get_receipt_data(user_addr, &GUID::id(&ballot.guid));

      if (approve_reject) {
        ballot.votes_approve = ballot.votes_approve - weight;
      } else {
        ballot.votes_reject = ballot.votes_reject - weight;
      };

      let ivoted = borrow_global_mut<IVoted>(user_addr);
      Vector::remove(&mut ivoted.elections, idx);
    }

    /// The handler for a third party contract may wish to extend the ballot deadline.
    /// DANGER: the thirdparty ballot contract needs to know what it is doing. If this ballot object is exposed to end users it's game over.

    public fun extend_deadline<Data: copy + store>(ballot: &mut Ballot<Data>, new_epoch: u64) {
      
      ballot.extended_deadline = new_epoch;
    }

    /// A third party contract can optionally call this function to extend the deadline to extend ballots in competitive situations.
    /// we may need to extend the ballot if on the last day (TBD a wider window) the vote had a big shift in favor of the minority vote.
    /// All that needs to be done, is on the return of vote(), to then call this function. 
    /// It's a useful feature, but it will not be included by default in all votes.

    public fun maybe_auto_competitive_extend<Data: copy + store>(ballot: &mut Ballot<Data>):u64  {

      let epoch = DiemConfig::get_current_epoch();

      // TODO: The exension window below of 1 day is not sufficient to make
      // much difference in practice (the threshold is most likely reached at that point).

      // Are we on the last day of voting (extension window)? If not exit
      if (epoch == ballot.extended_deadline || epoch == ballot.cfg_deadline) { return ballot.extended_deadline };

      if (is_competitive(ballot)) {
        // we may have extended already, but we don't want to extend more than once per day.
        if (ballot.extended_deadline > epoch) { return ballot.extended_deadline };

        // extend the deadline by 1 day
        ballot.extended_deadline = epoch + 1;
      };


      ballot.extended_deadline
    }

    fun is_competitive<Data: copy + store>(ballot: &Ballot<Data>): bool {
      let (prev_lead, prev_trail, prev_lead_updated, prev_trail_updated) = if (ballot.last_epoch_approve > ballot.last_epoch_reject) {
        // if the "approve" vote WAS leading.
        (ballot.last_epoch_approve, ballot.last_epoch_reject, ballot.votes_approve, ballot.votes_reject)
        
      } else {
        (ballot.last_epoch_reject, ballot.last_epoch_approve, ballot.votes_reject, ballot.votes_approve)
      };


      // no votes yet 
      if (prev_lead == 0 && prev_trail == 0) { return false }; 
      if (prev_lead_updated == 0 && prev_trail_updated == 0) { return false};

      let prior_margin = ((prev_lead - prev_trail) * PCT_SCALE) / (prev_lead + prev_trail);


      // the current margin may have flipped, so we need to check the direction of the vote.
      // if so then give an automatic extensions
      if (prev_lead_updated < prev_trail_updated) {
        return true
      } else {
        let current_margin = (prev_lead_updated - prev_trail_updated) * PCT_SCALE / (prev_lead_updated + prev_trail_updated);

        if (current_margin - prior_margin > MINORITY_EXT_MARGIN) {
          return true
        }
      };
      false
    }

    /// stop tallying if the expiration is passed or the threshold has been met.
    fun maybe_tally<Data: copy + store>(ballot: &mut Ballot<Data>) {
      let total_votes = ballot.votes_approve + ballot.votes_reject;

      assert!(ballot.max_votes >= total_votes, Errors::invalid_state(EVOTES_GREATER_THAN_ENROLLMENT));

      // figure out the turnout
      let m = FixedPoint32::create_from_rational(total_votes, ballot.max_votes);

      ballot.tally_turnout = FixedPoint32::multiply_u64(PCT_SCALE, m); // scale up
      // calculate the dynamic threshold needed.
      let t = get_threshold_from_turnout(total_votes, ballot.max_votes);
      // check the threshold that needs to be met met turnout
      ballot.tally_approve = FixedPoint32::multiply_u64(PCT_SCALE, FixedPoint32::create_from_rational(ballot.votes_approve, total_votes));
      // the first vote which crosses the threshold causes the poll to end.
      if (ballot.tally_approve > t) {

        // before marking it pass, make sure the minimum quorum was met
        // by default 12.50%
        if (ballot.tally_turnout > ballot.cfg_min_turnout) {
          let epoch = DiemConfig::get_current_epoch();

          if (ballot.provisional_pass_epoch == 0) {
            // automatically passing once the threshold is reached disadvantages inactive participants. We propose it takes one vote plus one day once reaching threshold.
            ballot.provisional_pass_epoch = epoch;
          } else if (epoch > ballot.provisional_pass_epoch) {
            // multiple days may have passed since the provisional pass.
            ballot.completed = true;
            ballot.tally_pass = true;
          }
        }
      }
    }

    // TODO: this should probably use Decimal.move
    // can't multiply FixedPoint32 types directly.
    public fun get_threshold_from_turnout(voters: u64, max_votes: u64): u64 {
      // let's just do a line

      let turnout = FixedPoint32::create_from_rational(voters, max_votes);
      let turnout_scaled_x = FixedPoint32::multiply_u64(PCT_SCALE, turnout); // scale to two decimal points.
      // only implemeting the negative slope case. Unsure why the other is needed.

      assert!(THRESH_AT_LOW_TURNOUT_Y1 > THRESH_AT_HIGH_TURNOUT_Y2, Errors::invalid_state(EVOTE_CALC_PARAMS));

      // the minimum passing threshold is the low turnout threshold.
      // same for the maximum turnout threshold.
      if (turnout_scaled_x < LOW_TURNOUT_X1) {
        return THRESH_AT_LOW_TURNOUT_Y1
      } else if (turnout_scaled_x > HIGH_TURNOUT_X2) {
        return THRESH_AT_HIGH_TURNOUT_Y2
      };


      let abs_m = FixedPoint32::create_from_rational(
        (THRESH_AT_LOW_TURNOUT_Y1 - THRESH_AT_HIGH_TURNOUT_Y2), (HIGH_TURNOUT_X2 - LOW_TURNOUT_X1)
      );

      let abs_mx = FixedPoint32::multiply_u64(LOW_TURNOUT_X1, *&abs_m);
      let b = THRESH_AT_LOW_TURNOUT_Y1 + abs_mx;
      let y =  b - FixedPoint32::multiply_u64(turnout_scaled_x, *&abs_m);

      return y
    }

    fun make_receipt(user_sig: &signer, vote_id: &ID, approve_reject: bool, weight: u64) acquires IVoted {

      let user_addr = Signer::address_of(user_sig);

      let receipt = VoteReceipt {
        guid: *vote_id,
        approve_reject: approve_reject,
        weight: weight,
      };

      if (!exists<IVoted>(user_addr)) {
        let ivoted = IVoted {
          elections: Vector::empty(),
        };
        move_to<IVoted>(user_sig, ivoted);
      };

      let (idx, is_found) = find_prior_vote_idx(user_addr, vote_id);

      // for safety remove the old vote if it exists.
      let ivoted = borrow_global_mut<IVoted>(user_addr);
      if (is_found) {
        Vector::remove(&mut ivoted.elections, idx);
      };
      Vector::push_back(&mut ivoted.elections, receipt);
    }

    fun find_prior_vote_idx(user_addr: address, vote_id: &ID): (u64, bool) acquires IVoted {
      if (!exists<IVoted>(user_addr)) {
        return (0, false)
      };
      
      let ivoted = borrow_global<IVoted>(user_addr);
      let len = Vector::length(&ivoted.elections);
      let i = 0;
      while (i < len) {
        let receipt = Vector::borrow(&ivoted.elections, i);
        if (&receipt.guid == vote_id) {
          return (i, true)
        };
        i = i + 1;
      };

      return (0, false)
    }

    fun get_vote_receipt(user_addr: address, idx: u64): VoteReceipt acquires IVoted {
      let ivoted = borrow_global<IVoted>(user_addr);
      let r = Vector::borrow(&ivoted.elections, idx);
      return *r
    }

    //////// GETTERS ////////
    /// get the ballot id
    public fun get_ballot_id<Data: copy + store>(ballot: &Ballot<Data>): ID {
      return GUID::id(&ballot.guid)
    }

    /// get current tally
    public fun get_tally<Data: copy + store>(ballot: &Ballot<Data>): u64 {
      let total = ballot.votes_approve + ballot.votes_reject;
      if (ballot.votes_approve + ballot.votes_reject > ballot.max_votes) {
        return 0
      };
      if (ballot.max_votes == 0) {
        return 0
      };
      return FixedPoint32::multiply_u64(PCT_SCALE, FixedPoint32::create_from_rational(total, ballot.max_votes))
    }

    /// is it complete and what's the result
    public fun complete_result<Data: copy + store>(ballot: &Ballot<Data>): (bool, bool) {
      (ballot.completed, ballot.tally_pass)
    }


    /// gets the receipt data
    // should return an OPTION.
    public fun get_receipt_data(user_addr: address, vote_id: &ID): (bool, u64) acquires IVoted {
      let (idx, found) = find_prior_vote_idx(user_addr, vote_id);
      if (found) {
          let v = get_vote_receipt(user_addr, idx);
          return (v.approve_reject, v.weight)
        };
      return (false, 0)
    } 
  }

  // // TODO: Fix publishing on test harness.
  // // see test _meta_import_vote.move
  // // There's an issue with the test harness, where it cannot publish the module
  // // task 2 'run'. lines 31-51:
  // // Error: error[E03002]: unbound module
  // // /var/folders/0s/7kz0td0j5pqffbc143hq52bm0000gn/T/.tmp3EAMzm:3:9
  // // 
  // //      use 0x1::GUID;
  // //          ^^^^^^^^^ Invalid 'use'. Unbound module: '0x1::GUID'

  module DummyTestVote {

    use DiemFramework::ParticipationVote::{Self, Ballot};
    use Std::GUID;
    use DiemFramework::Testnet;

    struct Vote has key {
      ballot: Ballot<EmptyType>,
    }

    struct EmptyType has store, copy {}

    // initialize this data on the address of the election contract
    public fun init(
      sig: &signer,
      data: EmptyType,
      deadline: u64,
      max_vote_enrollment: u64,
      max_extensions: u64,
      
    ): GUID::ID {
      assert!(Testnet::is_testnet(), 0);
      let cap = GUID::gen_create_capability(sig);
      let ballot = ParticipationVote::new_ballot<EmptyType>(&cap, data, deadline, max_vote_enrollment, max_extensions);

      let id = ParticipationVote::get_ballot_id<EmptyType>(&ballot);
      move_to(sig, Vote { ballot });
      id
    }

    public fun vote(sig: &signer, election_addr: address, weight: u64, approve_reject: bool) acquires Vote {
      assert!(Testnet::is_testnet(), 0);
      let vote = borrow_global_mut<Vote>(election_addr);
      ParticipationVote::vote<EmptyType>(&mut vote.ballot, sig, approve_reject, weight);
    }

    public fun retract(sig: &signer, election_addr: address) acquires Vote {
      assert!(Testnet::is_testnet(), 0);
      let vote = borrow_global_mut<Vote>(election_addr);
      ParticipationVote::retract<EmptyType>(&mut vote.ballot, sig);
    }

    public fun get_id(election_addr: address): GUID::ID acquires Vote {
      assert!(Testnet::is_testnet(), 0);
      let vote = borrow_global_mut<Vote>(election_addr);
      ParticipationVote::get_ballot_id(&vote.ballot)
    }

    public fun get_result(election_addr: address): (bool, bool) acquires Vote {
      let vote = borrow_global_mut<Vote>(election_addr);
      ParticipationVote::complete_result<EmptyType>(&vote.ballot)
    }

  }
}