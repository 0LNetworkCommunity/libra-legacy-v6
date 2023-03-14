///////////////////////////////////////////////////////////////////////////
// 0L Module
// VoteLib
// Intatiate different types of user interactive voting
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

    // Any user account can create an election.
    // usually a smart contract will be the one to create the election 
    // connected to some contract logic.
    // The contract may have multiple ballots at a given time.
    // Historical completed ballots are also stored in a separate vector.

    struct Ballot has key, store { // Note, this is a hot potato. Any methods chaning it must return the struct to caller.
      guid: GUID,
      name: vector<u8>, // TODO: change to ascii string
      cfg_min_deadline: u64, // deadline is at the END of this epoch (cfg_min_deadline + 1 stops taking votes)
      cfg_max_deadline: u64, // if 0 then no max. Election can run until threshold is met.
      cfg_min_turnout: u64,
      cfg_minority_extension: bool,
      in_progress: bool,
      max_votes: u64, // what's the entire universe of votes. i.e. 100% turnout
      // vote_tickets: VoteTicket, // the tickets that can be used to vote, which will be deducted as votes are cast. It is initialized with the max_votes.
      // Note the developer needs to be aware that if the right to vote changes throughout the period of the election (more coins, participants etc) then the max_votes and tickets could skew from expected results. Vote tickets can be distributed in advance.
      votes_approve: u64, // the running tally of approving votes,
      votes_reject: u64, // the running tally of rejecting votes,
      epochs_extended: u64, // how many times the deadline has been extended
      tally_turnout: FixedPoint32::FixedPoint32, // final turnout
      tally_pass: bool, // if it passed, for archival purposes
    }

    struct VoteReceipt has key, store, drop, copy { 
      guid: GUID::ID,
      approve_reject: bool,
      weight: u64,
    }
    struct IVoted has key {
      elections: vector<VoteReceipt>,
    }


    public fun new(sig: &signer, name: vector<u8>): Ballot {
        Ballot {
          guid: GUID::create(sig),
          name: name,
          cfg_min_deadline: 0,
          cfg_max_deadline: 0,
          cfg_min_turnout: 12,
          cfg_minority_extension: true,
          in_progress: true,
          max_votes: 0,
          votes_approve: 0,
          votes_reject: 0,
          epochs_extended: 0,
          tally_turnout: FixedPoint32::create_from_raw_value(0),
          tally_pass: false,
        }
    }

    // Only the contract, which is the keeper of the Ballot, can allow a user to temporarily hold the Ballot struct to update the vote. The user cannot arbiltrarily update the vote, with an arbitrary number of votes.
    // This is a hot potato, it cannot be dropped.

    public fun vote(ballot: &mut Ballot, user: &signer, approve_reject: bool, weight: u64) acquires IVoted {

      // check if this person voted already.
      // If the vote is the same directionally (approve, reject), exit early.
      // otherwise, need to subtract the old vote and add the new vote.
      let user_addr = Signer::address_of(user);
      let (idx, is_found) = find_prior_vote_idx(user_addr, &GUID::id(&ballot.guid));

      if (is_found) {
        let vote = get_vote_receipt(user_addr, idx);
        if (vote.approve_reject != approve_reject) {
          // subtract the old vote
          if (approve_reject) {
            // if the new vote is approval, remove old votes from rejected
            ballot.votes_reject = ballot.votes_reject - vote.weight;
          } else {
            // the new vote is a rejection, 
            ballot.votes_approve = ballot.votes_approve - vote.weight;
          };
        }
      };

      // in every case, add the new vote
      if (approve_reject) {
        ballot.votes_approve = ballot.votes_approve + weight;
      } else {
        ballot.votes_reject = ballot.votes_reject + weight;
      };

      // this will handle the case of updating the receipt in case this is a second vote.
      make_receipt(user, &GUID::id(&ballot.guid), approve_reject, weight);

      // always tally on each vote

      // ballot
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
    public fun get_ballot_id(ballot: &Ballot): ID {
      return GUID::id(&ballot.guid)
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

    //////// TEST ////////
    public fun test() {
      // no op
    }
  }

  //// TODO: Fix publishing on test harness.
  //// see test _meta_import_vote.move
  //// There's an issue with the test harness, where it cannot publish the module
  //// task 2 'run'. lines 31-51:
  //// Error: error[E03002]: unbound module
  //// /var/folders/0s/7kz0td0j5pqffbc143hq52bm0000gn/T/.tmp3EAMzm:3:9
  //// 
  ////      use 0x1::GUID;
  ////          ^^^^^^^^^ Invalid 'use'. Unbound module: '0x1::GUID'

  module DummyTestVote {

    use DiemFramework::ParticipationVote::{Self, Ballot};
    use Std::GUID;
    use DiemFramework::Testnet;

    struct Vote has key {
      ballot: Ballot,
    }

    // initialize this data on the address of the election contract
    public fun init(sig: &signer): GUID::ID {
      assert!(Testnet::is_testnet(), 0);
      let ballot = ParticipationVote::new(sig, b"please vote");
      let id = ParticipationVote::get_ballot_id(&ballot);
      move_to(sig, Vote { ballot });
      id
    }

    public fun vote(sig: &signer, election_addr: address, weight: u64, approve_reject: bool) acquires Vote {
      assert!(Testnet::is_testnet(), 0);
      let vote = borrow_global_mut<Vote>(election_addr);
      ParticipationVote::vote(&mut vote.ballot, sig, approve_reject, weight);
    }

    public fun get_id(election_addr: address): GUID::ID acquires Vote {
      assert!(Testnet::is_testnet(), 0);
      let vote = borrow_global_mut<Vote>(election_addr);
      ParticipationVote::get_ballot_id(&vote.ballot)
  }
}
}