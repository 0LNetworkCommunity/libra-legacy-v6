address 0x1 {

  module OracleBridge {
    use 0x1::Vector;
    use 0x1::Signer;
    use 0x1::LibraSystem;
    use 0x1::Upgrade;
    use 0x1::LibraBlock;
    use 0x1::CoreAddresses;
    use 0x1::LCS;
    // use 0x1::Bridge;
    // use 0x1::Event;

      resource struct Bridge {
        eth: vector<Election>
        //Other oracles, price, BTC header, etc.
  
      }
  
      struct Vote {
        validator: address,
        hash: vector<u8>,
        ol_party: address,
        foreign_party: vector<u8>,
        value: u64,
      }
  
      struct VoteCount {
        vote: Vote,
        validators: vector<address>,
      }

    fun fresh_guid(ol_party: address, foreign_party: vector<u8>, value: u64, eth_header: vector<u8>): vector<u8> {
        Vector::append(&mut eth_header, foreign_party);
        let sender_bytes = LCS::to_bytes(&ol_party);
        Vector::append(&mut eth_header, sender_bytes);

        let count_bytes = LCS::to_bytes(&value);
        Vector::append(&mut eth_header, count_bytes);

        eth_header
    }

      //TODO should be an Event  Handler
      struct Election {
        // id of the upgrade oracle
        id: u64,                         // 1
  
        // Info of the current window
        validators_voted: vector<address>,  // Each validator can only vote once in the current window
        vote_counts: vector<VoteCount>,     // Stores counts for each suggested payload
        votes: vector<Vote>,                // All the received votes
        vote_window: u64,                   // End of the current window, in block height
        version_id: u64,                    // Version id of the current window
        consensus: VoteCount,
      }
  
      public fun initialize(vm: &signer) {
        if (Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS()) {
          move_to(vm, Bridge { eth: Vector::empty<Election>() });
          // call initialization of upgrade
          Upgrade::initialize(vm);
        } 
      }
  
      public fun handler (
        sender: &signer,
        id: u64, 
        ol_party: address,
        foreign_party: vector<u8>,
        value: u64,
        eth_header: vector<u8>,
      ) acquires Bridge {
        // receives payload from oracle_tx.move
        // Check the sender is a validator. 
        assert(LibraSystem::is_validator(Signer::address_of(sender)), 11111); // TODO: error code
        let validator = Signer::address_of(sender);
        let current_height = LibraBlock::get_current_block_height();

        // TODO: Bridges have ids
        let eth_bridge = &mut borrow_global_mut<Bridge>(CoreAddresses::LIBRA_ROOT_ADDRESS()).eth;
        
        let upgrade_oracle = Vector::borrow_mut<Election>(eth_bridge, id);
  
        // check if consensus not reached within window, and qualifies as a new round
        let is_new_round = current_height > upgrade_oracle.vote_window;
  
        if (is_new_round) {
          enter_new_upgrade_round(upgrade_oracle, current_height);
        }; 
  
        // if the sender has voted, do nothing
        if (Vector::contains<address>(&upgrade_oracle.validators_voted, &validator)) {return};
        
        let validator_vote = Vote {
          validator: validator,
          hash: fresh_guid(ol_party, copy foreign_party, value, eth_header),
          ol_party: ol_party,
          foreign_party: foreign_party,
          value: value
        };
        Vector::push_back(&mut upgrade_oracle.votes, copy validator_vote);
        Vector::push_back(&mut upgrade_oracle.validators_voted, validator);

        increment_vote_count(
          &mut upgrade_oracle.vote_counts,
          validator_vote,
          validator
        );

        tally_upgrade(upgrade_oracle);
      }
  
      fun increment_vote_count(
        vote_counts: &mut vector<VoteCount>,
        vote: Vote,
        validator: address
      ) {
        let i = 0;
        let len = Vector::length(vote_counts);
        while (i < len) {
            let entry = Vector::borrow_mut(vote_counts, i);

            // if voted the same
            if (&entry.vote.hash == &vote.hash) {
              Vector::push_back(&mut entry.validators, validator);
              return
            };
            i = i + 1;
        };
        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, validator);
        Vector::push_back(vote_counts, VoteCount{vote: copy vote, validators: validators});
      }
  
      fun check_consensus(vote_counts: &vector<VoteCount>, threshold: u64): VoteCount {
        let i = 0;
        let len = Vector::length(vote_counts);
        while (i < len) {
            let entry = Vector::borrow(vote_counts, i);
            if (Vector::length(&entry.validators) >= threshold) {

              // Consensus should trigger an event for the Bridge.

              return *entry
            };
            i = i + 1;
        };
        VoteCount {
          vote: null_vote(),
          validators: Vector::empty<address>()
        }
      }


      // public fun emit(account: &signer, i: u64) {
      //   let addr = Signer::address_of(account);

      //   let handle = borrow_global_mut<Bridge::Handle>(addr);

      //   Event::emit_event(&mut handle.h, Bridge::AnEvent { i })
      // }
  
      fun null_vote():Vote {
        Vote {
          validator: 0x0,
          hash: Vector::empty<u8>(),
          ol_party: 0x0,
          foreign_party: Vector::empty<u8>(),
          value: 0,
        }

      }
      fun enter_new_upgrade_round(upgrade_oracle: &mut Election, height: u64) {
        upgrade_oracle.version_id = upgrade_oracle.version_id + 1;
        upgrade_oracle.validators_voted = Vector::empty<address>();
        upgrade_oracle.vote_counts = Vector::empty<VoteCount>();
        upgrade_oracle.votes = Vector::empty<Vote>();
        // TODO: change to Epochs instead of height. Could possibly be an argument as well.
        // Setting the window to be approx two 24h periods.
        upgrade_oracle.vote_window = height + 1000000;
        upgrade_oracle.consensus = VoteCount {
          vote: null_vote(), 
          validators: Vector::empty<address>(),
        };
      }
  
      // check to see if threshold is reached every time receiving a vote
      fun tally_upgrade (upgrade_oracle: &mut Election) {
        let validator_num = LibraSystem::validator_set_size();
        let threshold = validator_num * 2 / 3;

        if (Vector::length(&upgrade_oracle.vote_counts) > 0) {
          upgrade_oracle.consensus = check_consensus(&upgrade_oracle.vote_counts, threshold);

        }
      }
  
      // // Function call for vm to check consensus
      // public fun check_upgrade(vm: &signer) acquires Bridge {
      //   assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 11111); // TODO: error code
      //   let upgrade_oracle = &mut borrow_global_mut<Bridge>(CoreAddresses::LIBRA_ROOT_ADDRESS()).upgrade;
  
      //   let payload = *&upgrade_oracle.consensus.data;
      //   let validators = *&upgrade_oracle.consensus.validators;
  
      //   if (!Vector::is_empty(&payload)) {
      //     Upgrade::set_update(vm, *&payload); 
      //     let current_height = LibraBlock::get_current_block_height();
      //     Upgrade::record_history(vm, upgrade_oracle.version_id, payload, validators, current_height);
      //     enter_new_upgrade_round(upgrade_oracle, current_height);
      //   }
      // }
  
      // public fun test_helper_query_oracle_votes(): vector<address> acquires Bridge {
      //   assert(Testnet::is_testnet(), 123401011000);
      //   let s = borrow_global<Bridge>(0x0);
      //   let len = Vector::length<Vote>(&s.upgrade.votes);
    
      //   let voters = Vector::empty<address>();
      //   let i = 0;
      //   while (i < len) {
      //     let e = Vector::borrow<Vote>(&s.upgrade.votes, i);
      //     Vector::push_back(&mut voters, e.validator);
      //     i = i + 1;
    
      //   };
      //   voters
      // }
    }
  }
