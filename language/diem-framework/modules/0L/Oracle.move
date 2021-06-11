address 0x1 {
///////////////////////////////////////////////////////////////////////////
// File Prefix for errors: 1500
///////////////////////////////////////////////////////////////////////////
  module Oracle {
    use 0x1::Vector;
    use 0x1::Signer;
    use 0x1::Errors;
    use 0x1::Testnet;
    use 0x1::DiemSystem;
    use 0x1::Upgrade;
    use 0x1::DiemBlock;
    use 0x1::CoreAddresses;
  
      struct Oracles has key {
        upgrade: UpgradeOracle
        //Other oracles, price, BTC header, etc.
  
      }
  
      struct Vote has drop, store {
        validator: address,
        data: vector<u8>,
        version_id: u64,
        // More stuff?
      }
  
      struct VoteCount has copy, drop, store {
        data: vector<u8>,
        validators: vector<address>,
      }
  
      struct UpgradeOracle has store {
        // id of the upgrade oracle
        id: u64,                            // 1
  
        // Info of the current window
        validators_voted: vector<address>,  // Each validator can only vote once in the current window
        vote_counts: vector<VoteCount>,     // Stores counts for each suggested payload
        votes: vector<Vote>,                // All the received votes
        vote_window: u64,                   // End of the current window, in block height
        version_id: u64,                    // Version id of the current window
        consensus: VoteCount,
      }
  
     // Function code: 01
      public fun initialize(vm: &signer) {
        if (Signer::address_of(vm) == CoreAddresses::DIEM_ROOT_ADDRESS()) {
          move_to(vm, Oracles { 
            upgrade: UpgradeOracle {
                id: 1,
                validators_voted: Vector::empty<address>(),
                vote_counts: Vector::empty<VoteCount>(),
                votes: Vector::empty<Vote>(),
                vote_window: 1000, //Every n blocks
                version_id: 0,
                consensus: VoteCount{
                  data: Vector::empty<u8>(), 
                  validators: Vector::empty<address>(),
                },
              }
          },
          // other oracles
        );

        // call initialization of upgrade
        Upgrade::initialize(vm);
        } 
      }
  
      // Function code: 02
      public fun handler (sender: &signer, id: u64, data: vector<u8>) acquires Oracles {
        // receives payload from oracle_tx.move
        // Check the sender is a validator. 
        assert(DiemSystem::is_validator(Signer::address_of(sender)), Errors::requires_role(150002)); 
  
        if (id == 1) {
          upgrade_handler(sender, data);
        }
        // put else if cases for other oracles
      }
  
      fun upgrade_handler (sender: &signer, data: vector<u8>) acquires Oracles {
        let current_height = DiemBlock::get_current_block_height();
        let upgrade_oracle = &mut borrow_global_mut<Oracles>(CoreAddresses::DIEM_ROOT_ADDRESS()).upgrade;
  
        // check if qualifies as a new round
        let is_new_round = current_height > upgrade_oracle.vote_window;
  
        if (is_new_round) {
          enter_new_upgrade_round(upgrade_oracle, current_height);
        }; 
  
        // if the sender has voted, do nothing
        if (Vector::contains<address>(&upgrade_oracle.validators_voted, &Signer::address_of(sender))) {return};
        
        let validator_vote = Vote {
                validator: Signer::address_of(sender),
                data: copy data,
                version_id: *&upgrade_oracle.version_id,
        };
        Vector::push_back(&mut upgrade_oracle.votes, validator_vote);
        Vector::push_back(&mut upgrade_oracle.validators_voted, Signer::address_of(sender));
        increment_vote_count(&mut upgrade_oracle.vote_counts, data, Signer::address_of(sender));
        tally_upgrade(upgrade_oracle);
      }
  
      fun increment_vote_count(vote_counts: &mut vector<VoteCount>, data: vector<u8>, validator: address) {
        let i = 0;
        let len = Vector::length(vote_counts);
        while (i < len) {
            let entry = Vector::borrow_mut(vote_counts, i);
            if (Vector::compare(&entry.data, &data)) {
              Vector::push_back(&mut entry.validators, validator);
              return
            };
            i = i + 1;
        };
        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, validator);
        Vector::push_back(vote_counts, VoteCount{data: copy data, validators: validators});
      }
  
      fun check_consensus(vote_counts: &vector<VoteCount>, threshold: u64): VoteCount {
        let i = 0;
        let len = Vector::length(vote_counts);
        while (i < len) {
            let entry = Vector::borrow(vote_counts, i);
            if (Vector::length(&entry.validators) >= threshold) {
              return *entry
            };
            i = i + 1;
        };
        VoteCount{
          data: Vector::empty<u8>(), 
          validators: Vector::empty<address>(),
        }
      }
  
      fun enter_new_upgrade_round(upgrade_oracle: &mut UpgradeOracle, height: u64) {
        upgrade_oracle.version_id = upgrade_oracle.version_id + 1;
        upgrade_oracle.validators_voted = Vector::empty<address>();
        upgrade_oracle.vote_counts = Vector::empty<VoteCount>();
        upgrade_oracle.votes = Vector::empty<Vote>();
        // TODO: change to Epochs instead of height. Could possibly be an argument as well.
        // Setting the window to be approx two 24h periods.
        upgrade_oracle.vote_window = height + 1000000;
        upgrade_oracle.consensus = VoteCount{
          data: Vector::empty<u8>(), 
          validators: Vector::empty<address>(),
        };
      }
  
      // check to see if threshold is reached every time receiving a vote
      fun tally_upgrade (upgrade_oracle: &mut UpgradeOracle) {
        let validator_num = DiemSystem::validator_set_size();
        let threshold = validator_num * 2 / 3;
        let result = check_consensus(&upgrade_oracle.vote_counts, threshold);
  
        if (!Vector::is_empty(&result.data)) {
          upgrade_oracle.consensus = result;
        }
      }
  
      // Function call for vm to check consensus
      // Function code: 03
      public fun check_upgrade(vm: &signer) acquires Oracles {
        assert(Signer::address_of(vm) == CoreAddresses::DIEM_ROOT_ADDRESS(), Errors::requires_role(150003)); 
        let upgrade_oracle = &mut borrow_global_mut<Oracles>(CoreAddresses::DIEM_ROOT_ADDRESS()).upgrade;
  
        let payload = *&upgrade_oracle.consensus.data;
        let validators = *&upgrade_oracle.consensus.validators;
  
        if (!Vector::is_empty(&payload)) {
          Upgrade::set_update(vm, *&payload); 
          let current_height = DiemBlock::get_current_block_height();
          Upgrade::record_history(vm, upgrade_oracle.version_id, payload, validators, current_height);
          enter_new_upgrade_round(upgrade_oracle, current_height);
        }
      }

      // Function code: 04
      public fun test_helper_query_oracle_votes(): vector<address> acquires Oracles {
        assert(Testnet::is_testnet(), Errors::invalid_state(150004));
        let s = borrow_global<Oracles>(0x0);
        let len = Vector::length<Vote>(&s.upgrade.votes);
    
        let voters = Vector::empty<address>();
        let i = 0;
        while (i < len) {
          let e = Vector::borrow<Vote>(&s.upgrade.votes, i);
          Vector::push_back(&mut voters, e.validator);
          i = i + 1;
    
        };
        voters
      }
    }
  }
