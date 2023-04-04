//  Demo of implementation of TurnoutTally
address DiemFramework { 

  // // TODO: Fix publishing on test harness.
  // // see test _meta_import_vote.move
  // // There's an issue with the test harness, where it cannot publish the module
  // // task 2 'run'. lines 31-51:
  // // Error: error[E03002]: unbound module
  // // /var/folders/0s/7kz0td0j5pqffbc143hq52bm0000gn/T/.tmp3EAMzm:3:9
  // // 
  // //      use 0x1::GUID;
  // //          ^^^^^^^^^ Invalid 'use'. Unbound module: '0x1::GUID'

  module TurnoutTallyDemo {

    use DiemFramework::TurnoutTally::{Self, TurnoutTally};
    use DiemFramework::Ballot::{Self, BallotTracker};

    use Std::GUID;
    use Std::Signer;
    use Std::Vector;
    use Std::Option::Option;
    use DiemFramework::Testnet;

    struct Vote<D> has key {
      tracker: BallotTracker<D>,
      enrollment: vector<address>
    }

    struct EmptyType has store, drop {}

    // initialize this data on the address of the election contract
    public fun init(
      sig: &signer,
      
    ) {
      assert!(Testnet::is_testnet(), 0);

      let tracker = Ballot::new_tracker<TurnoutTally<EmptyType>>();
      
      move_to<Vote<TurnoutTally<EmptyType>>>(sig, Vote { 
        tracker,
        enrollment: Vector::empty()
      });
    }

    public fun propose_ballot_by_owner(sig: &signer, voters: u64, duration: u64) acquires Vote {
      assert!(Testnet::is_testnet(), 0);
      let cap = GUID::gen_create_capability(sig);
      let noop = EmptyType {};

      let t = TurnoutTally::new_tally_struct<EmptyType>(noop, voters, duration, 0);

      let vote = borrow_global_mut<Vote<TurnoutTally<EmptyType>>>(Signer::address_of(sig));

      Ballot::propose_ballot<TurnoutTally<EmptyType>>(&mut vote.tracker, &cap, t);
    }

     public fun vote(sig: &signer, election_addr: address, uid: &GUID::ID, weight: u64, approve_reject: bool): Option<bool> acquires Vote {
      assert!(Testnet::is_testnet(), 0);
      let vote = borrow_global_mut<Vote<TurnoutTally<EmptyType>>>(election_addr);
      let ballot = Ballot::get_ballot_by_id_mut<TurnoutTally<EmptyType>>(&mut vote.tracker, uid);
      let tally = Ballot::get_type_struct_mut<TurnoutTally<EmptyType>>(ballot);
      TurnoutTally::vote<EmptyType>(sig, tally, uid, approve_reject, weight)
    }

    public fun retract(sig: &signer, uid: &GUID::ID, election_addr: address) acquires Vote {
      assert!(Testnet::is_testnet(), 0);
      let vote = borrow_global_mut<Vote<TurnoutTally<EmptyType>>>(election_addr);
      let ballot = Ballot::get_ballot_by_id_mut<TurnoutTally<EmptyType>>(&mut vote.tracker, uid);
      let tally = Ballot::get_type_struct_mut<TurnoutTally<EmptyType>>(ballot);
      TurnoutTally::retract<EmptyType>(tally, uid, sig);
    }

  }
}