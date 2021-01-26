///////////////////////////////////////////////////////////////////
// 0L Module
// MinerState
///////////////////////////////////////////////////////////////////

address 0x1 {
  module MinerState {
    use 0x1::VDF;
    use 0x1::Vector;
    use 0x1::CoreAddresses;
    use 0x1::ValidatorUniverse;
    use 0x1::Signer;
    use 0x1::LibraConfig;
    use 0x1::Globals;
    use 0x1::Hash;
    use 0x1::Testnet;
    use 0x1::Stats;
    use 0x1::FullnodeState;
    // Struct to store information about a VDF proof submitted
    struct Proof {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
    }

    // Struct to encapsulate information about the state of a miner
    resource struct MinerProofHistory {
        previous_proof_hash: vector<u8>,
        verified_tower_height: u64, // user's latest verified_tower_height
        latest_epoch_mining: u64,
        count_proofs_in_epoch: u64,
        epochs_validating_and_mining: u64,
        contiguous_epochs_validating_and_mining: u64,
        epochs_since_last_account_creation: u64
    }

    // Creates proof blob object from input parameters
    // Permissions: PUBLIC, ANYONE can call this function.
    public fun create_proof_blob(
      challenge: vector<u8>,
      difficulty: u64,
      solution: vector<u8>
    ): Proof {
       Proof {
         challenge,
         difficulty,
         solution,
      }
    }

    // Helper function for genesis to process genesis proofs.
    // Permissions: PUBLIC, ONLY VM, AT GENESIS.
    public fun genesis_helper (
      vm_sig: &signer,
      miner_sig: &signer,
      challenge: vector<u8>,
      solution: vector<u8>
    ) acquires MinerProofHistory{
      // In rustland the vm_genesis creates a Signer for the miner. So the SENDER is not the same and the Signer.

      //TODO: Previously in OLv3 is_genesis() returned true. How to check that this is part of genesis? is_genesis returns false here.
      // assert(LibraTimestamp::is_genesis(), 130101024010);
      init_miner_state(miner_sig, &challenge, &solution);

      // TODO: Move this elsewhere? 
      // Initialize stats for first validator set from rust genesis. 
      let node_addr = Signer::address_of(miner_sig);
      Stats::init_address(vm_sig, node_addr);
    }

    // Function index: 03
    // Permissions: PUBLIC, SIGNER, TEST ONLY
   public fun test_helper(
      miner_sig: &signer,
      difficulty: u64,
      challenge: vector<u8>,
      solution: vector<u8>
    ) acquires MinerProofHistory {
      assert(Testnet::is_testnet(), 130102014010);
      //doubly check this is in test env.
      assert(Globals::get_epoch_length() == 60, 130102024010);

      move_to<MinerProofHistory>(miner_sig, MinerProofHistory{
        previous_proof_hash: Vector::empty(),
        verified_tower_height: 0u64,
        latest_epoch_mining: 0u64,
        count_proofs_in_epoch: 0u64,
        epochs_validating_and_mining: 0u64,
        contiguous_epochs_validating_and_mining: 0u64,
        epochs_since_last_account_creation: 10u64, // is not rate-limited
      });

      // Needs difficulty to test between easy and hard mode.
      let proof = Proof {
        challenge,
        difficulty,  
        solution,
      };

      verify_and_update_state(Signer::address_of(miner_sig), proof, false);
      FullnodeState::val_init(miner_sig);

    }

    // This function verifies the proof and commits to chain.
    // Function index: 03
    // Permissions: PUBLIC, ANYONE
    public fun commit_state(
      miner_sign: &signer,
      proof: Proof
    ) acquires MinerProofHistory {

      //NOTE: Does not check that the Sender is the Signer. Which we must skip for the onboarding transaction.

      // Get address, assumes the sender is the signer.
      let miner_addr = Signer::address_of(miner_sign);

      // Abort if not initialized.
      assert(exists<MinerProofHistory>(miner_addr), 130103011021);

      // Get vdf difficulty constant. Will be different in tests than in production.
      let difficulty_constant = Globals::get_difficulty();

      // Skip this check on local tests, we need tests to send different difficulties.
      if (!Testnet::is_testnet()){
        assert(&proof.difficulty == &difficulty_constant, 130103021010);
      };
      
      verify_and_update_state(miner_addr, proof, true);

      // TODO: This should not increment for validators in set.
      // Including LibraSystem::is_validator causes a dependency cycling
      FullnodeState::inc_proof(miner_sign);
    }

    // Function to verify a proof blob and update a MinerProofHistory
    // Permissions: private function.
    fun verify_and_update_state(
      miner_addr: address,
      proof: Proof,
      steady_state: bool
    ) acquires MinerProofHistory {
      // Get a mutable ref to the current state
      let miner_history = borrow_global_mut<MinerProofHistory>(miner_addr);

      // For onboarding transaction the VDF has already been checked.
      // only do this in steady state.
      if (steady_state) {
        //If not genesis proof, check hash 
        assert(&proof.challenge == &miner_history.previous_proof_hash, 130108031010);      
      };

      let valid = VDF::verify(&proof.challenge, &proof.difficulty, &proof.solution);
      assert(valid, 130108041021);


      miner_history.previous_proof_hash = Hash::sha3_256(*&proof.solution);
      
      // Increment the verified_tower_height
      if (steady_state) {
        miner_history.verified_tower_height = miner_history.verified_tower_height + 1;
        miner_history.count_proofs_in_epoch = miner_history.count_proofs_in_epoch + 1;
      } else {
        miner_history.verified_tower_height = 0;
        miner_history.count_proofs_in_epoch = 1
      };
    
      miner_history.latest_epoch_mining = LibraConfig::get_current_epoch();
    }

    // Checks that the validator has been mining above the count threshold
    // Note: this is only called on a validator successfully meeting the validation thresholds (different than mining threshold). So the function presumes the validator is in good standing for that epoch.
    // Permissions: private function
    fun update_metrics(account: &signer, miner_addr: address) acquires MinerProofHistory {
      // The goal of update_metrics is to confirm that a miner participated in consensus during
      // an epoch, but also that there were mining proofs submitted in that epoch.
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 130109014010);

      // Miner may not have been initialized. Simply return in this case (don't abort)
      if( !exists<MinerProofHistory>(miner_addr) ) { return };


      // Check that there was mining and validating in period.
      // Account may not have any proofs submitted in epoch, since the resource was last emptied.
      let passed = node_above_thresh(account, miner_addr);
      let miner_history = borrow_global_mut<MinerProofHistory>(miner_addr);
      
      // Update statistics.
      if (passed) {
          let this_epoch = LibraConfig::get_current_epoch();
          miner_history.latest_epoch_mining = this_epoch;

          miner_history.epochs_validating_and_mining = miner_history.epochs_validating_and_mining + 1u64;

          miner_history.contiguous_epochs_validating_and_mining = miner_history.contiguous_epochs_validating_and_mining + 1u64;

          miner_history.epochs_since_last_account_creation = miner_history.epochs_since_last_account_creation + 1u64;
      } else {
        // didn't meet the threshold, reset this count
        miner_history.contiguous_epochs_validating_and_mining = 0;
      };

      // This is the end of the epoch, reset the count of proofs
      miner_history.count_proofs_in_epoch = 0u64;
    }


    public fun node_above_thresh(_account: &signer, miner_addr: address): bool acquires MinerProofHistory {
      let miner_history= borrow_global<MinerProofHistory>(miner_addr);
      return (miner_history.count_proofs_in_epoch > Globals::get_mining_threshold())
    }
    // Get weight of validator identified by address
    // Permissions: public, only VM can call this function.
    // TODO: change this name.
    public fun get_validator_weight(account: &signer, miner_addr: address): u64 acquires MinerProofHistory {
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 130110014010);

      // Miner may not have been initialized. (don't abort, just return 0)
      if( !exists<MinerProofHistory>(miner_addr)){
        return 0
      };

      // Update the statistics.
      let miner_history= borrow_global_mut<MinerProofHistory>(miner_addr);
      let this_epoch = LibraConfig::get_current_epoch();
      miner_history.latest_epoch_mining = this_epoch;

      // Return its weight
      miner_history.epochs_validating_and_mining
    }

    // Used at end of epoch with reconfig bulk_update the MinerState with the vector of validators from current epoch.
    // Permissions: PUBLIC, ONLY VM.
    public fun reconfig(vm: &signer) acquires MinerProofHistory {
      // Check permissions
      let sender = Signer::address_of(vm);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 130111014010);

      // Get list of validators from ValidatorUniverse
      let eligible_validators = ValidatorUniverse::get_eligible_validators(vm);

      // Iterate through validators and call update_metrics for each validator that had proofs this epoch
      let size = Vector::length<address>(&eligible_validators);
      let i = 0;
      while (i < size) {
          let val = *Vector::borrow(&eligible_validators, i);

          // For testing: don't call update_metrics unless there is account state for the address.
          if (exists<MinerProofHistory>(val)){
              update_metrics(vm, val);
          };
          i = i + 1;
      };
    }

    // Function to initialize miner state
    // Permissions: PUBLIC, Signer, Validator only
    public fun init_miner_state(miner_sig: &signer, challenge: &vector<u8>, solution: &vector<u8>) acquires MinerProofHistory {
      
      // NOTE Only Signer can update own state.
      // Should only happen once.
      assert(!exists<MinerProofHistory>(Signer::address_of(miner_sig)), 130112011021);
      // LibraAccount calls this.
      // Exception is LibraAccount which can simulate a Signer.
      // Initialize MinerProofHistory object and give to miner account
      move_to<MinerProofHistory>(miner_sig, MinerProofHistory{
        previous_proof_hash: Vector::empty(),
        verified_tower_height: 0u64,
        latest_epoch_mining: 0u64,
        count_proofs_in_epoch: 1u64,
        epochs_validating_and_mining: 0u64,
        contiguous_epochs_validating_and_mining: 0u64,
        epochs_since_last_account_creation: 0u64,
      });

      let difficulty = Globals::get_difficulty();
      let proof = Proof {
        challenge: *challenge,
        difficulty,  
        solution: *solution,
      };
      
      verify_and_update_state(Signer::address_of(miner_sig), proof, false);
      // Subsidy::queue_fullnode_subisdy(Signer::address_of(miner_sig));
      //also add the miner to validator universe
      //TODO: #254 ValidatorUniverse::add_validators need to check permission.
      // Note: this should be in LibraAccount but causes cyclic dependency.
      ValidatorUniverse::add_validator(miner_sig);
      FullnodeState::val_init(miner_sig);
      FullnodeState::inc_proof(miner_sig);
    }


    // Process and check the first proof blob submitted for validity (includes correct address)
    // Permissions: PUBLIC, ANYONE. (used in onboarding transaction).
    public fun first_challenge_includes_address(new_account_address: address, challenge: &vector<u8>) {
      // Checks that the preimage/challenge of the FIRST VDF proof blob contains a given address.
      // This is to ensure that the same proof is not sent repeatedly, since all the minerstate is on a
      // the address of a miner.
      // Note: The bytes of the miner challenge is as follows:
      //         32 // 0L Key
      //         +64 // chain_id
      //         +8 // iterations/difficulty
      //         +1024; // statement

      // Calling native function to do this parsing in rust
      // The auth_key must be at least 32 bytes long
      assert(Vector::length(challenge) >= 32, 130113011000);
      let (parsed_address, _auth_key) = VDF::extract_address_from_challenge(challenge);
      // Confirm the address is corect and included in challenge
      assert(new_account_address == parsed_address, 130113021010);
    }

    // Get latest epoch mined by node on given address
    // Permissions: public ony VM can call this function.
    public fun get_miner_latest_epoch(account: &signer, addr: address): u64 acquires MinerProofHistory {
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 130114014010);
      let addr_state = borrow_global<MinerProofHistory>(addr);
      *&addr_state.latest_epoch_mining
    }

    public fun reset_rate_limit(node_addr: address) acquires MinerProofHistory {
      let state = borrow_global_mut<MinerProofHistory>(node_addr);
      state.epochs_since_last_account_creation = 0;
    }

    ////////////////////
    /// Public APIs ///
    ///////////////////

    // Returns number of epochs for input miner's state
    // Permissions: PUBLIC, ANYONE
    // TODO: Rename
    public fun get_epochs_mining(node_addr: address): u64 acquires MinerProofHistory {
      borrow_global<MinerProofHistory>(node_addr).epochs_validating_and_mining
    }

    // Returns if the miner is above the account creation rate-limit
    // Permissions: PUBLIC, ANYONE
    // TODO: Rename
    public fun rate_limit_create_acc(node_addr: address): bool acquires MinerProofHistory {
      borrow_global<MinerProofHistory>(node_addr).epochs_since_last_account_creation > 6;
      true
    }

    ////////////////////
    // TEST HELPERS ///
    ////////////////////

    public fun test_helper_mock_mining(sender: &signer,  count: u64) acquires MinerProofHistory {
      assert(Testnet::is_testnet(), 130115014011);
      let state = borrow_global_mut<MinerProofHistory>(Signer::address_of(sender));
      state.count_proofs_in_epoch = count;
    }

    public fun test_helper_mock_mining_vm(vm: &signer, addr: address, count: u64) acquires MinerProofHistory {
      assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), 130115014011);

      assert(Testnet::is_testnet(), 130115014011);
      let state = borrow_global_mut<MinerProofHistory>(addr);
      state.count_proofs_in_epoch = count;
    }

    // Permissions: PUBLIC, VM, TESTING 
    public fun test_helper_mock_reconfig(account: &signer, miner_addr: address) acquires MinerProofHistory{
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 130115014010);
      assert(Testnet::is_testnet()== true, 130115014011);
      update_metrics(account, miner_addr);
    }

    // Get weight of validator identified by address
    // Permissions: PUBLIC, ANYONE, TESTING 
    public fun test_helper_get_height(miner_addr: address): u64 acquires MinerProofHistory {
      assert(Testnet::is_testnet()== true, 130115014011);

      assert(exists<MinerProofHistory>(miner_addr), 130115021000);

      let state = borrow_global<MinerProofHistory>(miner_addr);
      *&state.verified_tower_height
    }

    public fun test_helper_get_contiguous(miner_addr: address): u64 acquires MinerProofHistory {
      assert(Testnet::is_testnet()== true, 130115014011);
      borrow_global<MinerProofHistory>(miner_addr).contiguous_epochs_validating_and_mining
    }

    public fun test_helper_get_count(miner_addr: address): u64 acquires MinerProofHistory {
      assert(Testnet::is_testnet()== true, 130115014011);
      borrow_global<MinerProofHistory>(miner_addr).count_proofs_in_epoch
    }

    public fun test_helper_set_rate_limit(miner_addr: address, value: u64) acquires MinerProofHistory {
      assert(Testnet::is_testnet()== true, 130115014011);
      let state = borrow_global_mut<MinerProofHistory>(miner_addr);
      state.epochs_since_last_account_creation = value;
    }

    public fun test_helper_hash(miner_addr: address): vector<u8> acquires MinerProofHistory {
      assert(Testnet::is_testnet()== true, 130115014011);
      *&borrow_global<MinerProofHistory>(miner_addr).previous_proof_hash
    }
  }
}