address DiemFramework {
///////////////////////////////////////////////////////////////////////////
// File Prefix for errors: 1500
///////////////////////////////////////////////////////////////////////////
  module Oracle {
    use Std::Vector;
    use Std::Signer;
    use Std::Errors;
    use DiemFramework::Testnet;
    use DiemFramework::DiemSystem;
    use DiemFramework::Upgrade;
    use DiemFramework::DiemBlock;
    use Std::Hash;
    use DiemFramework::NodeWeight;
    use DiemFramework::VectorHelper;

      //possible vote types
      const VOTE_TYPE_ONE_FOR_ONE: u8 = 0;
      const VOTE_TYPE_PROPORTIONAL_VOTING_POWER: u8 = 1;
      const VOTE_TYPE_MAX: u8 = 1; //change if new voting types are added

      //selected vote type for oracle
      const VOTE_TYPE_UPGRADE: u8 = 1; //VOTE_TYPE_PROPORTIONAL_VOTING_POWER;
      const DELEGATION_ENABLED_UPGRADE: bool = true;

      //Errors
      const VOTE_TYPE_INVALID: u64 = 150001;
      const DELEGATION_NOT_ENABLED: u64 = 150002;
      const VOTE_ALREADY_DELEGATED: u64 = 150003;
      const DELEGATION_NOT_PRESENT: u64 = 150004;
      const DUPLICATE_VOTE: u64 = 150005;

      struct Oracles has key {
        upgrade: UpgradeOracle
        //Other oracles, price, BTC header, etc.
  
      }
  
      struct Vote has store, drop {
        validator: address,
        data: vector<u8>,
        version_id: u64,
        weight: u64, //Defaults to 1, may switch to be proportional to voting power
        // More stuff?
      }
  
      struct VoteCount has store, copy, drop {
        data: vector<u8>,
        validators: vector<address>,
        hash: vector<u8>,
        total_weight: u64,
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

      struct VoteDelegation has key{
        vote_delegated: bool,
        delegates: vector<address>,
        delegated_to_address: address, 
      }

  
     // Function code: 01
      public fun initialize(vm: &signer) {
        if (Signer::address_of(vm) == @DiemRoot) {
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
                  hash: Vector::empty<u8>(), 
                  validators: Vector::empty<address>(),
                  total_weight: 0,
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
      public fun handler (sender: &signer, id: u64, data: vector<u8>) acquires Oracles, VoteDelegation {
        // receives payload from oracle_tx.move
        // Check the sender is a validator. 
        assert!(DiemSystem::is_validator(Signer::address_of(sender)), Errors::requires_role(150002)); 
  
        if (id == 1) {
          upgrade_handler(Signer::address_of(sender), copy data);
          if (DELEGATION_ENABLED_UPGRADE && exists<VoteDelegation>(Signer::address_of(sender))) {
            let del = borrow_global<VoteDelegation>(Signer::address_of(sender));
            let l = Vector::length<address>(&del.delegates);
            let i = 0;
            let hash = Hash::sha2_256(data);
            while (i < l) {
              let addr = *Vector::borrow<address>(&del.delegates, i);
              if(DiemSystem::is_validator(addr)) {
                upgrade_handler_hash(addr, copy hash);
              };
              i = i + 1;
            };
          };
        }
        else if (id == 2) {
          upgrade_handler_hash(Signer::address_of(sender), copy data);
          if (DELEGATION_ENABLED_UPGRADE && exists<VoteDelegation>(Signer::address_of(sender))) {
            let del = borrow_global<VoteDelegation>(Signer::address_of(sender));
            let l = Vector::length<address>(&del.delegates);
            let i = 0;
            while (i < l) {
              let addr = *Vector::borrow<address>(&del.delegates, i);
              if(DiemSystem::is_validator(addr)) {
                upgrade_handler_hash(addr, copy data);
              };
              i = i + 1;
            };
          };
        };
        // put else if cases for other oracles
      }
      
      fun upgrade_handler (sender: address, data: vector<u8>) acquires Oracles {
        let current_height = DiemBlock::get_current_block_height();
        let upgrade_oracle = &mut borrow_global_mut<Oracles>(@DiemRoot).upgrade;
  
        // check if qualifies as a new round
        let is_new_round = current_height > upgrade_oracle.vote_window;
  
        if (is_new_round) {
          enter_new_upgrade_round(upgrade_oracle, current_height);
        }; 
  
        // if the sender has voted, do nothing
        if (Vector::contains<address>(&upgrade_oracle.validators_voted, &sender)) {return};
        
        let vote_weight = get_weight(sender, VOTE_TYPE_UPGRADE);

        let validator_vote = Vote {
                validator: sender,
                data: Hash::sha2_256(copy data),
                version_id: *&upgrade_oracle.version_id,
                weight: vote_weight,
        };
        Vector::push_back(&mut upgrade_oracle.votes, validator_vote);
        Vector::push_back(&mut upgrade_oracle.validators_voted, sender);
        increment_vote_count(&mut upgrade_oracle.vote_counts, data, sender, vote_weight);
        tally_upgrade(upgrade_oracle, VOTE_TYPE_UPGRADE);
      }
      
      fun upgrade_handler_hash (sender: address, data: vector<u8>) acquires Oracles {
        let current_height = DiemBlock::get_current_block_height();
        let upgrade_oracle = &mut borrow_global_mut<Oracles>(@DiemRoot).upgrade;
  
        // check if qualifies as a new round
        let is_new_round = current_height > upgrade_oracle.vote_window;
  
        if (is_new_round) {
          //If it's a new round, user must submit a data payload, not hash only
          return
        }; 
  
        // if the sender has voted, do nothing
        if (Vector::contains<address>(&upgrade_oracle.validators_voted, &sender)) {
          assert!(false, Errors::invalid_argument(DUPLICATE_VOTE));
        };
 
        let vote_weight = get_weight(sender, VOTE_TYPE_UPGRADE);
        
        let validator_vote = Vote {
                validator: sender,
                data: copy data,
                version_id: *&upgrade_oracle.version_id,
                weight: vote_weight, 
        };
        
        let vote_sent = increment_vote_count_hash(
          &mut upgrade_oracle.vote_counts, data, sender, vote_weight
        );

        if (vote_sent) {
          Vector::push_back(&mut upgrade_oracle.votes, validator_vote);
          Vector::push_back(&mut upgrade_oracle.validators_voted, sender);
          tally_upgrade(upgrade_oracle, VOTE_TYPE_UPGRADE);
        };
      }

      public fun revoke_my_votes(sender: &signer) acquires Oracles, VoteDelegation {
        let addr = Signer::address_of(sender);
        revoke_vote(addr);
        let del = borrow_global<VoteDelegation>(Signer::address_of(sender));
        let l = Vector::length<address>(&del.delegates);
        let i = 0;
        while (i < l) {
          let addr = *Vector::borrow<address>(&del.delegates, i);
          revoke_vote(addr);
          i = i + 1;
        };
      }

      fun revoke_vote(addr: address) acquires Oracles{
        let upgrade_oracle = &mut borrow_global_mut<Oracles>(@DiemRoot).upgrade;
        let (is_found, idx) = Vector::index_of<address>(&upgrade_oracle.validators_voted, &addr);
        if (is_found) {
          Vector::remove(&mut upgrade_oracle.votes, idx);
          Vector::remove(&mut upgrade_oracle.validators_voted, idx);
          tally_upgrade(upgrade_oracle, VOTE_TYPE_UPGRADE);
        };
      }      
  
      fun increment_vote_count(vote_counts: &mut vector<VoteCount>, data: vector<u8>, validator: address, vote_weight: u64) {
        let data_hash = Hash::sha2_256(copy data);
        let i = 0;
        let len = Vector::length(vote_counts);
        while (i < len) {
            let entry = Vector::borrow_mut(vote_counts, i);
            if (VectorHelper::compare(&entry.hash, &data_hash)) {
              Vector::push_back(&mut entry.validators, validator);
              entry.total_weight = entry.total_weight + vote_weight;
              return
            };
            i = i + 1;
        };
        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, validator);
        Vector::push_back(vote_counts, VoteCount{data: copy data, hash: data_hash, validators: validators, total_weight: vote_weight});
      }

      //returns true if vote is submitted successfully, false if it was not (no match found)
      fun increment_vote_count_hash(vote_counts: &mut vector<VoteCount>, data: vector<u8>, validator: address, vote_weight: u64): bool {
        let i = 0;
        let len = Vector::length(vote_counts);
        while (i < len) {
            let entry = Vector::borrow_mut(vote_counts, i);
            if (VectorHelper::compare(&entry.hash, &data)) {
              Vector::push_back(&mut entry.validators, validator);
              entry.total_weight = entry.total_weight + vote_weight;
              return true
            };
            i = i + 1;
        };
        false
      }
  
      fun check_consensus(vote_counts: &vector<VoteCount>, threshold: u64): VoteCount {
        let i = 0;
        let len = Vector::length(vote_counts);
        while (i < len) {
            let entry = Vector::borrow(vote_counts, i);
            if (entry.total_weight >= threshold) {
              return *entry
            };
            i = i + 1;
        };
        VoteCount{
          data: Vector::empty<u8>(), 
          hash: Vector::empty<u8>(), 
          validators: Vector::empty<address>(),
          total_weight: 0,
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
          hash: Vector::empty<u8>(),
          validators: Vector::empty<address>(),
          total_weight: 0,
        };
      }

      fun vm_expire_upgrade(vm: &signer) acquires Oracles {
        assert!(Signer::address_of(vm) == @DiemRoot, Errors::requires_role(150003));
        let upgrade_oracle = &mut borrow_global_mut<Oracles>(@DiemRoot).upgrade;
        let threshold = get_threshold(VOTE_TYPE_PROPORTIONAL_VOTING_POWER);
        let result = check_consensus(&upgrade_oracle.vote_counts, threshold);
        upgrade_oracle.consensus = result;
        upgrade_oracle.vote_window = DiemBlock::get_current_block_height() - 1;
      }      
  
      // check to see if threshold is reached every time receiving a vote
      // TODO: Not sure we still want to do this every time as tallying is more
      // costly when using node weight (as the threshold must be summed), fine for now. 
      fun tally_upgrade(upgrade_oracle: &mut UpgradeOracle, type: u8) {
        let threshold = get_threshold(type);
        let result = check_consensus(&upgrade_oracle.vote_counts, threshold);
  
        if (!Vector::is_empty(&result.data)) {
          upgrade_oracle.consensus = result;
        }
      }
  
      // Function call for vm to check consensus
      // Function code: 03
      public fun check_upgrade(vm: &signer) acquires Oracles {
        assert!(Signer::address_of(vm) == @DiemRoot, Errors::requires_role(150003)); 
        let upgrade_oracle = &mut borrow_global_mut<Oracles>(@DiemRoot).upgrade;
  
        let payload = *&upgrade_oracle.consensus.data;
        let validators = *&upgrade_oracle.consensus.validators;
  
        if (!Vector::is_empty(&payload)) {
          Upgrade::set_update(vm, *&payload); 
          let current_height = DiemBlock::get_current_block_height();
          Upgrade::record_history(vm, upgrade_oracle.version_id, payload, validators, current_height);
          enter_new_upgrade_round(upgrade_oracle, current_height);
        }
      }

      fun get_weight (voter: address, type: u8): u64 {

        if (type == VOTE_TYPE_ONE_FOR_ONE) {
          1
        }
        else if (type == VOTE_TYPE_PROPORTIONAL_VOTING_POWER) {
          NodeWeight::proof_of_weight(voter)
        }
        else {
          assert!(false, Errors::invalid_argument(VOTE_TYPE_INVALID));
          1
        }

      }

      fun get_threshold (type: u8): u64 {
        if (type == VOTE_TYPE_ONE_FOR_ONE) {
          let validator_num = DiemSystem::validator_set_size();
          let threshold = validator_num * 2 / 3;
          threshold 
        }
        else if (type == VOTE_TYPE_PROPORTIONAL_VOTING_POWER) {
          calculate_proportional_voting_threshold()
        }
        else {
          assert!(false, Errors::invalid_argument(VOTE_TYPE_INVALID));
          1
        }
      }

      fun calculate_proportional_voting_threshold(): u64 {
        let val_set_size = DiemSystem::validator_set_size();
        let i = 0;
        let voting_power = 0;
        while (i < val_set_size) {
          let addr = DiemSystem::get_ith_validator_address(i);
          voting_power = voting_power + NodeWeight::proof_of_weight(addr);
          i = i + 1;
        };
        let threshold = voting_power * 2 / 3;
        threshold
      }

      public fun enable_delegation (sender: &signer) {
        if (!exists<VoteDelegation>(Signer::address_of(sender))) {
          move_to<VoteDelegation>(sender, VoteDelegation{
            vote_delegated: false,
            delegates: Vector::empty<address>(),
            delegated_to_address: Signer::address_of(sender),
          });
        }
      }

      public fun has_delegated (account: address): bool acquires VoteDelegation {
        if (exists<VoteDelegation>(account)) {
          let del = borrow_global<VoteDelegation>(account); 
          return del.vote_delegated
        };
        false
      }

      public fun check_number_delegates (addr: address): u64 acquires VoteDelegation {
        let del = borrow_global<VoteDelegation>(addr);
        Vector::length<address>(& del.delegates)

      }

      public fun delegate_vote (sender: &signer, vote_dest: address) acquires VoteDelegation{
        assert!(exists<VoteDelegation>(Signer::address_of(sender)), Errors::not_published(DELEGATION_NOT_ENABLED));

        // check if the receipient/destination has enabled delegation.
        assert!(exists<VoteDelegation>(vote_dest), Errors::not_published(DELEGATION_NOT_ENABLED));

        let del = borrow_global_mut<VoteDelegation>(Signer::address_of(sender)); 
        assert!(del.vote_delegated == false, Errors::invalid_state(VOTE_ALREADY_DELEGATED));
        
        del.vote_delegated = true;
        del.delegated_to_address = vote_dest;
        
        let del = borrow_global_mut<VoteDelegation>(vote_dest); 

        Vector::push_back<address>(&mut del.delegates, Signer::address_of(sender));

      }

      public fun remove_delegate_vote (sender: &signer) acquires VoteDelegation{
        assert!(exists<VoteDelegation>(Signer::address_of(sender)), Errors::not_published(DELEGATION_NOT_ENABLED));
        
        let del = borrow_global_mut<VoteDelegation>(Signer::address_of(sender));

        del.vote_delegated = false;
        let vote_dest = del.delegated_to_address;
        del.delegated_to_address = Signer::address_of(sender);

        //don't want to end up in a situation where delegation cannot be removed
        if (exists<VoteDelegation>(vote_dest)) {
          let del = borrow_global_mut<VoteDelegation>(vote_dest);

          let (b, loc) = Vector::index_of<address>(&del.delegates, &Signer::address_of(sender));
          if (b) {
            Vector::remove<address>(&mut del.delegates, loc);
          };
        };

      }

      public fun delegation_enabled_upgrade(): bool {
        DELEGATION_ENABLED_UPGRADE
      }

      public fun upgrade_vote_type(): u8 {
        VOTE_TYPE_UPGRADE
      }

      ////////// TEST HELPERS

      // Function code: 04
      public fun test_helper_query_oracle_votes(): vector<address> acquires Oracles {
        assert!(Testnet::is_testnet(), Errors::invalid_state(150004));
        let s = borrow_global<Oracles>(@0x0);
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

      public fun test_helper_check_upgrade(): bool acquires Oracles {
        assert!(Testnet::is_testnet(), Errors::invalid_state(150004)); 
        let upgrade_oracle = &borrow_global<Oracles>(
          @DiemRoot
        ).upgrade;
        let payload = *&upgrade_oracle.consensus.data;

        if (!Vector::is_empty(&payload)) {
          true
        }
        else {
          false
        }
      }


    }
  }
