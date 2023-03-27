address DiemFramework {

  /// This is an example of how to use VoteLib, to create a standalone poll.
  /// In this example we are making a naive DAO payment approval system.
  /// whenever the deadline passes, the next vote will trigger a tally
  /// and if the tally is successful, the payment will be made.
  /// If the tally is not successful, the payment will be rejected.
  module ExampleStandalonePoll {

    use DiemFramework::VoteLib::{Self, Vote};
    use Std::GUID;
    use Std::Vector;
    use Std::Signer;
    use Std::Errors;
    use Std::Option::{Self, Option};
    use DiemFramework::DiemConfig;

    const EINVALID_VOTE: u64 = 0;

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
      voters: vector<address>, // this is a list of voters who have voted. You may prefer to move the voted flag to the end user's address (or do a bloom filter).
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
    // /// Initialize poll struct which will be stored as-is on the account under Vote<Type>.
    // /// Developers who need more flexibility, can instead construct the Vote object and then wrap it in another struct on their third party module.
    // public fun standalone_init_poll_at_address<TallyType: drop + store>(
    //   sig: &signer,
    //   poll: Vote<TallyType>,
    // ) {
    //   move_to<Vote<TallyType>>(sig, poll)
    // }

    /// If the Vote is standalone at root of address, you can use thie function as long as the CreateCapability is available.
    public fun standalone_propose_ballot<TallyType: drop + store>(
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
      let addr = GUID::get_capability_address(guid_cap);
      let state = borrow_global_mut<ExamplePoll<TallyType>>(addr);
      let (found, idx, status_enum, _completed) = VoteLib::find_anywhere(&state.poll, uid);
      assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));
      let b = VoteLib::get_ballot_mut(poll, idx, status_enum);
      b.tally_type = tally_type;
    }

    // /// tuple if the ballot is (found, its index, its status enum, is it completed)
    // public fun standalone_find_anywhere<TallyType: drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID): (bool, u64, u8, bool) acquires Vote {
    //   let vote_address = GUID::get_capability_address(guid_cap);
    //   let poll = borrow_global_mut<Vote<TallyType>>(vote_address);
    //   find_anywhere(poll, uid)
    // }

    // // public fun standalone_get_tally_copy<TallyType: drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID): TallyType acquires Vote {
    // //   let vote_address = GUID::get_capability_address(guid_cap);
    // //   let poll = borrow_global_mut<Vote<TallyType>>(vote_address);
    // //   get_tally_copy(poll, uid)
    // // }

    // public fun standalone_complete_and_move<TallyType: drop + store>(guid_cap: &GUID::CreateCapability, uid: &GUID::ID, to_status_enum: u8) acquires Vote {
    //   let vote_address = GUID::get_capability_address(guid_cap);
    //   let poll = borrow_global_mut<Vote<TallyType>>(vote_address);
      
    //   let (found, idx, from_status_enum, _completed) = find_anywhere(poll, uid);
    //   assert!(found, Errors::invalid_argument(ENO_BALLOT_FOUND));

    //   let b = get_ballot_mut(poll, idx, from_status_enum);
    //   complete_ballot(b);
    //   move_ballot(poll, uid, from_status_enum, to_status_enum);

    // }


    /// The signer can always access a new GUID::CreateCapability
    /// On a multisig type account, will need to store the CreateCapability 
    /// wherever the multisig authorities can access it. Be careful ou there!
    // public fun init_empty_tally(sig: &signer) {
    //   let poll = VoteLib::new_poll<DummyTally>();


    //   let guid_cap = GUID::gen_create_capability(sig);

    //   VoteLib::standalone_init_poll_at_address<DummyTally>(sig, poll);

    //   VoteLib::standalone_propose_ballot<DummyTally>(&guid_cap, DummyTally {})

    // }


    public fun init_useful_tally(sig: &signer) {
      let poll = VoteLib::new_poll<UsefulTally<ExampleIssueData>>();


      let guid_cap = GUID::gen_create_capability(sig);

      // VoteLib::standalone_init_poll_at_address<UsefulTally<ExampleIssueData>>(sig, poll);

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

      // VoteLib::standalone_propose_ballot<UsefulTally<ExampleIssueData>>(&guid_cap, t);

      // store the capability in the account so it can be used later by someone other than the owner of the account. (e.g. a voter.)
      move_to(sig, VoteCapability { guid_cap });
    }


    // public fun propose_test_ballot(sig: &signer ) acquires VoteCapability {

    //     let poll = borrow_global_mut<Vote<UsefulTally<ExampleIssueData>>>(0x0);
        
    //     let t = UsefulTally {
    //     votes_for: 0,
    //     votes_against: 0,
    //     voters: Vector::empty(),
    //     deadline_epoch: DiemConfig::get_current_epoch() + 7,
    //     tally_result: Option::none<bool>(),
    //     issue_data: ExampleIssueData {
    //       pay_this_person: @0xDEADBEEF,
    //       amount: 0,
    //       description: b"hello world",
    //     }
    //   };


    // }
//     // The voting handlers are defined by the thrid party module NOT the VoteLib module. The VoteLib module only provides the APIs to move proposals from one list to another. The external contract needs to decide how that should happen.

//     public fun vote(sig: &signer, vote_address: address, id: &GUID::ID, vote_for: bool) acquires VoteCapability {

//       // get the GUID capability stored here
//       let cap = &borrow_global<VoteCapability>(vote_address).guid_cap;

//       let (found, _idx, status_enum, is_completed) = VoteLib::standalone_find_anywhere<UsefulTally<ExampleIssueData>>(cap, id);

//       assert!(found, Errors::invalid_argument(EINVALID_VOTE));
//       assert!(!is_completed, Errors::invalid_argument(EINVALID_VOTE));
//       // is a pending ballot
//       assert!(status_enum == 0, Errors::invalid_argument(EINVALID_VOTE));


//       // get_ballot_type

//       // check signer did not already vote
//       let t = VoteLib::standalone_get_tally_copy<UsefulTally<ExampleIssueData>>(cap, id);

//       // check if the signer has already voted
//       let signer_addr = Signer::address_of(sig);
//       let found = Vector::contains(&t.voters, &signer_addr);
//       assert!(!found, Errors::invalid_argument(0));

//       if (vote_for) {
//         t.votes_for = t.votes_for + 1;
//       } else {
//         t.votes_against = t.votes_against + 1;
//       };


//       // add the signer to the list of voters
//       Vector::push_back(&mut t.voters, signer_addr);
      

//       // update the tally

//       maybe_tally(&mut t);

//       // update the ballot
//       VoteLib::standalone_update_tally<UsefulTally<ExampleIssueData>>(cap, id,  copy t);


//       if (Option::is_some(&t.tally_result)) {
//         let passed = *Option::borrow(&t.tally_result);
//         let status_enum = if (passed) {
//           // run the payment handler
//           payment_handler(&t);
//           1 // approved
//         } else {
          
//           2 // rejected
//         };
//         // since we have a result lets update the VoteLib state
//         VoteLib::standalone_complete_and_move<UsefulTally<ExampleIssueData>>(cap, id, status_enum);

//       }

      


//     }

//     fun payment_handler(t: &UsefulTally<ExampleIssueData>) {
        
//           // do the action
//           // pay the person

                
//         let _payee = t.issue_data.pay_this_person;
//         let _amount = t.issue_data.amount;
//         let _description = *&t.issue_data.description;
//         // MAKE THE PAYMENT.
//     }

//     fun maybe_tally(t: &mut UsefulTally<ExampleIssueData>): Option<bool> {
//       // check if the tally is complete
//       // if so, move the tally to the completed list
//       // if not, do nothing

//       if (DiemConfig::get_current_epoch() > t.deadline_epoch) {
//         // tally is complete
//         // move the tally to the completed list
//         // call the action
//         if (t.votes_for > t.votes_against) {
//           t.tally_result = Option::some(true);
//         } else {
//           t.tally_result = Option::some(false);
//         }

//       };

//       *&t.tally_result

//     }

  }
}