///////////////////////////////////////////////////////////////////////////
// 0L Module
// VoteLib
// Intatiate different types of user interactive voting
///////////////////////////////////////////////////////////////////////////

// TODO: Move this to a separate address. Potentially has separate governance.
address DiemFramework { 

  module ParticipationVote {

    
    // This is a voting module which attempts to accomodate online voting where votes tend to happen:
    // 1. publicly
    // 2. asynchronously
    // 3. with a low turnout

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
    use Std::Errors;
    use DiemFramework::VectorHelper;


    /// A current active ballot with this name already exists.
    const EEXISTS_ACTIVE: u64 = 200010;
    /// A completed ballot with this name already exists.
    const EEXISTS_COMPLETED: u64 = 200011;
    
    // Any user account can create an election.
    // usually a smart contract will be the one to create the election 
    // connected to some contract logic.
    // The contract may have multiple ballots at a given time.
    // Historical completed ballots are also stored in a separate vector.
    struct MyElections has key {
      active: vector<Ballot>,
      completed: vector<Ballot>,
    }


    struct Ballot has key, store, drop {
      name: vector<u8>,
      cfg_min_deadline: u64, // deadline is at the END of this epoch (cfg_min_deadline + 1 stops taking votes)
      cfg_max_deadline: u64, // if 0 then no max. Election can run until threshold is met.
      cfg_min_turnout: u64,
      cfg_minority_extension: bool,
      in_progress: bool,
      max_votes: u64, // what's the entire universe of votes. i.e. 100% turnout
      votes_approve: u64, // the running tally of approving votes,
      votes_reject: u64, // the running tally of rejecting votes,
      epochs_extended: u64, // how many times the deadline has been extended
      tally_turnout: FixedPoint32::FixedPoint32, // final turnout
      tally_pass: bool, // if it passed, for archival purposes
    }

    // The user needs the elections struct initialized.
    fun maybe_init_elections(sig: &signer) {
      let addr = Signer::address_of(sig);
      if (!exists<MyElections>(addr)) {
        let elections = MyElections {
          active: Vector::empty(),
          completed: Vector::empty(),
        };
        move_to<MyElections>(sig, elections);
      }
    }

    // user can add a ballot. Names must be unique in both active and completed ballots.
    fun user_init_ballot(
      sig: &signer,
      name: vector<u8>,
      cfg_min_deadline: u64,
      cfg_max_deadline: u64,
      cfg_min_turnout: u64,
      cfg_minority_extension: bool
    ) acquires MyElections {
      maybe_init_elections(sig);

      let addr = Signer::address_of(sig);

      if (!exists<MyElections>(addr)) {
        maybe_init_elections(sig);
      };

      let (_, is_found_active) = find_index_ballot(addr, &name, false);
      assert!(!is_found_active, Errors::already_published(EEXISTS_ACTIVE));

      let (_, is_found_completed) = find_index_ballot(addr, &name, false);
      assert!(!is_found_completed, Errors::already_published(EEXISTS_COMPLETED));


      let new_ballot = Ballot {
          name: name,
          cfg_min_deadline: cfg_min_deadline,
          cfg_max_deadline: cfg_max_deadline,
          cfg_min_turnout: cfg_min_turnout,
          cfg_minority_extension: cfg_minority_extension,
          in_progress: true,
          max_votes: 0,
          votes_approve: 0,
          votes_reject: 0,
          epochs_extended: 0,
          tally_turnout: FixedPoint32::create_from_raw_value(0),
          tally_pass: false,
        };
      let elections = borrow_global_mut<MyElections>(addr);
      Vector::push_back(&mut elections.active, new_ballot);
    }

    fun find_index_ballot(election_addr: address, name: &vector<u8>, completed: bool): (u64, bool) acquires MyElections {
      if (exists<MyElections>(election_addr)) {
        let elections = borrow_global<MyElections>(election_addr);
        let list = if (completed) {
          &elections.completed
        } else {
          &elections.active
        };

        let len = Vector::length(list);
        let i = 0;
        while (i < len) {
          let ballot = Vector::borrow(&elections.active, i);
          if (VectorHelper::compare(&ballot.name, name)) {
            return (i, true)
          };
          i = i + 1;
        };
        (0, false)

      } else {
        (0, false)
      }
    }
    

  }
}