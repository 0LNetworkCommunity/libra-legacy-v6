///////////////////////////////////////////////////////////////////
// 0L Module
// MinerState
// Error Code = 1301
///////////////////////////////////////////////////////////////////

address 0x1 {
  /// # Summary 
  /// TODO
  module MinerState {
    use 0x1::Errors;
    use 0x1::CoreAddresses;
    use 0x1::FullnodeState;
    use 0x1::Globals;
    use 0x1::Hash;
    use 0x1::DiemConfig;
    use 0x1::Signer;
    use 0x1::StagingNet;
    use 0x1::Stats;
    use 0x1::Testnet;
    use 0x1::ValidatorConfig;
    use 0x1::VDF;
    use 0x1::Vector;

    const EPOCHS_UNTIL_ACCOUNT_CREATION: u64 = 6;

    /// a list of all miners' addresses TODO: When is this list updated? Can people be removed?
    struct MinerList has key {
      list: vector<address>
    }

    /// Struct to store information about a VDF proof submitted
    /// `challenge`: the seed for the proof 
    /// `difficulty`: the difficulty for the proof (higher difficulty -> longer proof time)
    /// `solution`: the solution for the proof (the result)
    struct Proof has drop {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
    }

    /// Struct to encapsulate information about the state of a miner
    /// `previous_proof_hash`: the hash of their latest proof (used as seed for next proof)
    /// `verified_tower_height`: the height of the miner's tower (more proofs -> higher tower)
    /// `latest_epoch_mining`: the latest epoch the miner submitted sufficient proofs (see GlobalConstants.epoch_mining_threshold)
    /// `count_proofs_in_epoch`: the number of proofs the miner has submitted in the current epoch 
    /// `epochs_validating_and_mining`: the cumulative number of epochs the miner has been mining above threshold TODO does this actually only apply to validators? 
    /// `contiguous_epochs_validating_and_mining`: the number of contiguous epochs the miner has been mining above threshold TODO does this actually only apply to validators?
    /// `epochs_since_last_account_creation`: the number of epochs since the miner last created a new account
    struct MinerProofHistory has key {
        previous_proof_hash: vector<u8>,
        verified_tower_height: u64, 
        latest_epoch_mining: u64,
        count_proofs_in_epoch: u64,
        epochs_validating_and_mining: u64,
        contiguous_epochs_validating_and_mining: u64,
        epochs_since_last_account_creation: u64
    }

    /// Create an empty list of miners 
    public fun init_list(vm: &signer) {
      CoreAddresses::assert_diem_root(vm);
      move_to<MinerList>(vm, MinerList {
        list: Vector::empty<address>()
      });  
    }

    /// returns true if miner at `addr` has been initialized 
    public fun is_init(addr: address):bool {
      exists<MinerProofHistory>(addr)
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

    /// add `sender` to the list of miners
    public fun add_self_list(sender: &signer) acquires MinerList {
      let addr = Signer::address_of(sender);
      increment_miners_list(addr);
    }

    /// Private, can only be called within module
    /// adds `miner` to list of miners 
    fun increment_miners_list(miner: address) acquires MinerList {
      if (exists<MinerList>(0x0)) {
        let state = borrow_global_mut<MinerList>(0x0);
        if (!Vector::contains<address>(&mut state.list, &miner)) {
          Vector::push_back<address>(&mut state.list, miner);
        }
      }
    }

    // Helper function for genesis to process genesis proofs.
    // Permissions: PUBLIC, ONLY VM, AT GENESIS.
    public fun genesis_helper (
      vm_sig: &signer, // In rustland the vm_genesis creates a Signer for the miner. So the SENDER is not the same as the Signer.
      miner_sig: &signer,
      challenge: vector<u8>,
      solution: vector<u8>
    ) acquires MinerProofHistory, MinerList {
      CoreAddresses::assert_diem_root(vm_sig);

      //TODO: Previously in OLv3 is_genesis() returned true. How to check that this is part of genesis? is_genesis returns false here.
      // assert(DiemTimestamp::is_genesis(), 130101024010);
      init_miner_state(miner_sig, &challenge, &solution);

      // TODO: Move this elsewhere? 
      // Initialize stats for first validator set from rust genesis. 
      let node_addr = Signer::address_of(miner_sig);
      Stats::init_address(vm_sig, node_addr);
    }

    /// This function is called to submit proofs to the chain 
    /// Note, the sender of this transaction can differ from the signer, to facilitate onboarding
    /// Function index: 01
    /// Permissions: PUBLIC, ANYONE
    public fun commit_state(
      miner_sign: &signer,
      proof: Proof
    ) acquires MinerProofHistory, MinerList {
      // Get address, assumes the sender is the signer.
      let miner_addr = Signer::address_of(miner_sign);

      // Abort if not initialized.
      assert(exists<MinerProofHistory>(miner_addr), Errors::not_published(130101));

      // Get vdf difficulty constant. Will be different in tests than in production.
      let difficulty_constant = Globals::get_difficulty();

      // Skip this check on local tests, we need tests to send different difficulties.
      if (!Testnet::is_testnet()){
        assert(&proof.difficulty == &difficulty_constant, Errors::invalid_argument(130102));
      };
      
      // Process the proof
      verify_and_update_state(miner_addr, proof, true);
    }

    // This function is called by the OPERATOR associated with node, it verifies the proof and commits to chain.
    // Function index: 02
    // Permissions: PUBLIC, ANYONE
    public fun commit_state_by_operator(
      operator_sig: &signer,
      miner_addr: address, 
      proof: Proof
    ) acquires MinerProofHistory, MinerList {

      // Check the signer is in fact an operator delegated by the owner.
      assert(ValidatorConfig::get_operator(miner_addr) == Signer::address_of(operator_sig), Errors::requires_role(130102));
      // Abort if not initialized.
      assert(exists<MinerProofHistory>(miner_addr), Errors::not_published(130102));

      // Get vdf difficulty constant. Will be different in tests than in production.
      let difficulty_constant = Globals::get_difficulty();

      // Skip this check on local tests, we need tests to send different difficulties.
      if (!Testnet::is_testnet()){
        assert(&proof.difficulty == &difficulty_constant, Errors::invalid_argument(130102));
      };
      
      // Process the proof
      verify_and_update_state(miner_addr, proof, true);
      
      // TODO: The operator mining needs its own struct to count mining.
      // For now it is implicit there is only 1 operator per validator, and that the fullnode state is the place to count.
      // This will require a breaking change to MinerState
      // FullnodeState::inc_proof_by_operator(operator_sig, miner_addr);
    }

    // Function to verify a proof blob and update a MinerProofHistory
    // Permissions: private function.
    // Function index: 03
    fun verify_and_update_state(
      miner_addr: address,
      proof: Proof,
      steady_state: bool
    ) acquires MinerProofHistory, MinerList {
      // Get a mutable ref to the current state
      let miner_history = borrow_global_mut<MinerProofHistory>(miner_addr);
      
      // If not genesis proof, check hash to ensure the proof continues the chain
      if (steady_state) {
        assert(&proof.challenge == &miner_history.previous_proof_hash, Errors::invalid_state(130103));      
      };

      let valid = VDF::verify(&proof.challenge, &proof.difficulty, &proof.solution);
      assert(valid, Errors::invalid_argument(130103));

      // add the miner to the miner list if not present
      increment_miners_list(miner_addr);

      // update the miner proof history (result is used as seed for next proof)
      miner_history.previous_proof_hash = Hash::sha3_256(*&proof.solution);
      
      // Increment the verified_tower_height
      if (steady_state) {
        miner_history.verified_tower_height = miner_history.verified_tower_height + 1;
        miner_history.count_proofs_in_epoch = miner_history.count_proofs_in_epoch + 1;
      } else {
        miner_history.verified_tower_height = 0;
        miner_history.count_proofs_in_epoch = 1
      };
    
      miner_history.latest_epoch_mining = DiemConfig::get_current_epoch();
    }

    // Checks that the validator has been mining above the count threshold
    // Note: this is only called on a validator successfully meeting the validation thresholds (different than mining threshold). 
    // So the function presumes the validator is in good standing for that epoch.
    // Permissions: private function
    // Function index: 04
    fun update_metrics(account: &signer, miner_addr: address) acquires MinerProofHistory {
      // The goal of update_metrics is to confirm that a miner participated in consensus during
      // an epoch, but also that there were mining proofs submitted in that epoch.
      CoreAddresses::assert_diem_root(account);

      // Miner may not have been initialized. Simply return in this case (don't abort)
      if(!is_init(miner_addr)) { return };

      // Check that there was mining and validating in period.
      // Account may not have any proofs submitted in epoch, since the resource was last emptied.
      let passed = node_above_thresh(account, miner_addr);
      let miner_history = borrow_global_mut<MinerProofHistory>(miner_addr);
      
      // Update statistics.
      if (passed) {
          let this_epoch = DiemConfig::get_current_epoch();
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

    /// Checks to see if miner submitted enough proofs to be considered compliant
    public fun node_above_thresh(_account: &signer, miner_addr: address): bool acquires MinerProofHistory {
      let miner_history= borrow_global<MinerProofHistory>(miner_addr);
      miner_history.count_proofs_in_epoch > Globals::get_mining_threshold()
    }

    // Get the number of epochs a validator has been validating and mining. 
    // Function code: 05
    public fun get_validator_epochs_validating_and_mining(miner_addr: address): u64 acquires MinerProofHistory {
      // Miner may not have been initialized. (don't abort, just return 0)
      if( !exists<MinerProofHistory>(miner_addr)){
        return 0
      };

      // Return its weight
      let miner_history= borrow_global_mut<MinerProofHistory>(miner_addr);
      miner_history.epochs_validating_and_mining
    }

    // Used at end of epoch with reconfig bulk_update the MinerState with the vector of validators from current epoch.
    // Permissions: PUBLIC, ONLY VM.
    public fun reconfig(vm: &signer, migrate_eligible_validators: &vector<address>) acquires MinerProofHistory, MinerList {
      // Check permissions
      CoreAddresses::assert_diem_root(vm);

      // check minerlist exists, or use eligible_validators to initialize.
      // Migration on hot upgrade
      if (!exists<MinerList>(0x0)) {
        move_to<MinerList>(vm, MinerList {
          list: *migrate_eligible_validators
        });
      };

      let minerlist_state = borrow_global_mut<MinerList>(0x0);

      // Iterate through validators and call update_metrics for each validator that had proofs this epoch
      let size = Vector::length<address>(&minerlist_state.list); 
      let i = 0;
      while (i < size) {
          let val = Vector::borrow(&minerlist_state.list, i); 

          // For testing: don't call update_metrics unless there is account state for the address.
          if (exists<MinerProofHistory>(*val)){
              update_metrics(vm, *val);
          };
          i = i + 1;
      };

      //reset miner list
      minerlist_state.list = Vector::empty<address>();

    }

    // Function to initialize miner state
    // Permissions: PUBLIC, Signer, Validator only
    // Function code: 07
    public fun init_miner_state(miner_sig: &signer, challenge: &vector<u8>, solution: &vector<u8>) acquires MinerProofHistory, MinerList {
      
      // NOTE Only Signer can update own state.
      // Should only happen once.
      assert(!exists<MinerProofHistory>(Signer::address_of(miner_sig)), Errors::requires_role(130107));
      // DiemAccount calls this.
      // Exception is DiemAccount which can simulate a Signer.
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

      // create the initial proof submission
      let difficulty = Globals::get_difficulty();
      let proof = Proof {
        challenge: *challenge,
        difficulty,  
        solution: *solution,
      };

      // TODO: should fullnode state happen here?
      // FullnodeState::init(miner_sig);

      //submit the proof
      verify_and_update_state(Signer::address_of(miner_sig), proof, false);
    }


    // Process and check the first proof blob submitted for validity (includes correct address)
    // Permissions: PUBLIC, ANYONE. (used in onboarding transaction).
    // Function code: 08
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
      assert(Vector::length(challenge) >= 32, Errors::invalid_argument(130108));
      let (parsed_address, _auth_key) = VDF::extract_address_from_challenge(challenge);
      // Confirm the address is corect and included in challenge
      assert(new_account_address == parsed_address, Errors::requires_address(130108));
    }

    // Get latest epoch mined by node on given address
    // Permissions: public ony VM can call this function.
    // Function code: 09
    public fun get_miner_latest_epoch(vm: &signer, addr: address): u64 acquires MinerProofHistory {
      CoreAddresses::assert_diem_root(vm);
      let addr_state = borrow_global<MinerProofHistory>(addr);
      *&addr_state.latest_epoch_mining
    }

    // Function to reset the timer for when an account can be created 
    // must be signed by the account being reset 
    // done as a part of the creation of new accounts. 
    public fun reset_rate_limit(miner: &signer) acquires MinerProofHistory {
      let state = borrow_global_mut<MinerProofHistory>(Signer::address_of(miner));
      state.epochs_since_last_account_creation = 0;
    }

    //////////////////////
    /// Public Getters ///
    /////////////////////

    // Returns number of epochs for input miner's state
    // Permissions: PUBLIC, ANYONE
    // TODO: Rename
    public fun get_miner_list(): vector<address> acquires MinerList {
      if (!exists<MinerList>(0x0)) {
        return Vector::empty<address>()  
      };
      *&borrow_global<MinerList>(0x0).list
    }

    // Returns number of epochs for input miner's state
    // Permissions: PUBLIC, ANYONE
    // TODO: Rename
    public fun get_epochs_mining(node_addr: address): u64 acquires MinerProofHistory {
      borrow_global<MinerProofHistory>(node_addr).epochs_validating_and_mining
    }

    // returns the number of proofs for a miner in the current epoch
    public fun get_count_in_epoch(miner_addr: address): u64 acquires MinerProofHistory {
      borrow_global<MinerProofHistory>(miner_addr).count_proofs_in_epoch
    }

    // Returns if the miner is above the account creation rate-limit
    // Permissions: PUBLIC, ANYONE
    public fun can_create_val_account(node_addr: address): bool acquires MinerProofHistory {
      if(Testnet::is_testnet() || StagingNet::is_staging_net()) return true;
      // check if rate limited, needs 7 epochs of validating.
      borrow_global<MinerProofHistory>(node_addr).epochs_since_last_account_creation > EPOCHS_UNTIL_ACCOUNT_CREATION
    }

    //////////////////
    // TEST HELPERS //
    //////////////////

    // Initiates a miner for a testnet
    // Function index: 10
    // Permissions: PUBLIC, SIGNER, TEST ONLY
    public fun test_helper(
        miner_sig: &signer,
        difficulty: u64,
        challenge: vector<u8>,
        solution: vector<u8>
      ) acquires MinerProofHistory, MinerList {
        assert(Testnet::is_testnet(), 130102014010);

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
        FullnodeState::init(miner_sig);

    }

    // Function index: 11
    // provides a different method to submit from the operator for use in tests where the operator cannot sign a transaction
    // Permissions: PUBLIC, SIGNER, TEST ONLY
    public fun test_helper_operator_submits(
      operator_addr: address, // Testrunner does not allow arbitrary accounts to submit txs, need to use address, so this will differ slightly from api
      miner_addr: address, 
      proof: Proof
    ) acquires MinerProofHistory, MinerList {
      assert(Testnet::is_testnet(), 130102014010);
      
      // Get address, assumes the sender is the signer.
      assert(ValidatorConfig::get_operator(miner_addr) == operator_addr, Errors::requires_address(130111));
      // Abort if not initialized.
      assert(exists<MinerProofHistory>(miner_addr), Errors::not_published(130111));

      // Get vdf difficulty constant. Will be different in tests than in production.
      let difficulty_constant = Globals::get_difficulty();

      // Skip this check on local tests, we need tests to send different difficulties.
      if (!Testnet::is_testnet()){
        assert(&proof.difficulty == &difficulty_constant, Errors::invalid_state(130111));
      };
      
      verify_and_update_state(miner_addr, proof, true);
    }

    // Function code: 12
    // Use in testing to mock mining without producing proofs
    public fun test_helper_mock_mining(sender: &signer,  count: u64) acquires MinerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130112));
      let state = borrow_global_mut<MinerProofHistory>(Signer::address_of(sender));
      state.count_proofs_in_epoch = count;
      FullnodeState::mock_proof(sender, count);
    }

    // Function code: 13
    // mocks mining for an arbitrary account from the vm 
    public fun test_helper_mock_mining_vm(vm: &signer, addr: address, count: u64) acquires MinerProofHistory {
      CoreAddresses::assert_diem_root(vm);

      assert(Testnet::is_testnet(), Errors::invalid_state(130113));
      let state = borrow_global_mut<MinerProofHistory>(addr);
      state.count_proofs_in_epoch = count;
    }

    // Permissions: PUBLIC, VM, TESTING 
    // Get the vm to trigger a reconfig for testing
    // Function code: 14
    public fun test_helper_mock_reconfig(account: &signer, miner_addr: address) acquires MinerProofHistory{
      CoreAddresses::assert_diem_root(account);
      assert(Testnet::is_testnet()== true, Errors::invalid_state(130114));
      update_metrics(account, miner_addr);
    }

    // Get weight of validator identified by address
    // Permissions: PUBLIC, ANYONE, TESTING 
    // Function code: 15
    public fun test_helper_get_height(miner_addr: address): u64 acquires MinerProofHistory {
      assert(Testnet::is_testnet()== true, Errors::invalid_state(130115));

      assert(exists<MinerProofHistory>(miner_addr), Errors::not_published(130115));

      let state = borrow_global<MinerProofHistory>(miner_addr);
      *&state.verified_tower_height
    }

    // Get the number of proofs for a miner in the current epoch
    public fun test_helper_get_count(miner_addr: address): u64 acquires MinerProofHistory {
        assert(Testnet::is_testnet(), 130115014011);
        borrow_global<MinerProofHistory>(miner_addr).count_proofs_in_epoch
    }

    // Function code: 16
    public fun test_helper_get_contiguous(miner_addr: address): u64 acquires MinerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130116));
      borrow_global<MinerProofHistory>(miner_addr).contiguous_epochs_validating_and_mining
    }


    // Function code: 17
    // Sets the epochs since last account creation variable to allow `miner_addr` to create a new account
    public fun test_helper_set_rate_limit(miner_addr: address, value: u64) acquires MinerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130117));
      let state = borrow_global_mut<MinerProofHistory>(miner_addr);
      state.epochs_since_last_account_creation = value;
    }

    // Sets the epochs validating and mining for `node_addr' to increase their weight in the testnet
    public fun test_helper_set_epochs_mining(node_addr: address, value: u64)acquires MinerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130117));

      let s = borrow_global_mut<MinerProofHistory>(node_addr);
      s.epochs_validating_and_mining = value;
    }

    // Function code: 18
    // returns the previous proof hash for `miner_addr`
    public fun test_helper_hash(miner_addr: address): vector<u8> acquires MinerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130118));
      *&borrow_global<MinerProofHistory>(miner_addr).previous_proof_hash
    }
  }
}