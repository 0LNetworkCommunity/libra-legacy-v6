///////////////////////////////////////////////////////////////////
// 0L Module
// TowerState
// Error Code = 1301
///////////////////////////////////////////////////////////////////

address 0x1 {

module TowerState {
    use 0x1::Errors;
    use 0x1::CoreAddresses;
    use 0x1::Globals;
    use 0x1::Hash;
    use 0x1::DiemConfig;
    use 0x1::Signer;
    use 0x1::Stats;
    use 0x1::StagingNet;
    use 0x1::Testnet;
    use 0x1::ValidatorConfig;
    use 0x1::VDF;
    use 0x1::Vector;

    const EPOCHS_UNTIL_ACCOUNT_CREATION: u64 = 14;

    /// A list of all miners' addresses 
    // reset at epoch boundary
    struct TowerList has key {
      list: vector<address>
    }

    /// To use in migration, and in future upgrade to deprecate.
    struct TowerStats has key {
      proofs_in_epoch: u64,
      validator_proofs: u64,
      fullnode_proofs: u64,
    }

    /// The struct to store the global count of proofs in 0x0
    struct TowerCounter has key {
      lifetime_proofs: u64,
      lifetime_validator_proofs: u64,
      lifetime_fullnode_proofs: u64,
      proofs_in_epoch: u64,
      validator_proofs_in_epoch: u64,
      fullnode_proofs_in_epoch: u64,
      validator_proofs_in_epoch_above_thresh: u64,
      fullnode_proofs_in_epoch_above_thresh: u64,
    }


    /// Struct to store information about a VDF proof submitted
    /// `challenge`: the seed for the proof 
    /// `difficulty`: the difficulty for the proof 
    ///               (higher difficulty -> longer proof time)
    /// `solution`: the solution for the proof (the result)
    struct Proof has drop {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
        security: u64,
    }

    /// Struct to encapsulate information about the state of a miner
    /// `previous_proof_hash`: the hash of their latest proof 
    ///     (used as seed for next proof)
    /// `verified_tower_height`: the height of the miner's tower 
    ///     (more proofs -> higher tower)
    /// `latest_epoch_mining`: the latest epoch the miner submitted sufficient
    ///     proofs (see GlobalConstants.epoch_mining_thres_lower)
    /// `count_proofs_in_epoch`: the number of proofs the miner has submitted 
    ///     in the current epoch 
    /// `epochs_validating_and_mining`: the cumulative number of epochs 
    ///     the miner has been mining above threshold 
    ///     TODO does this actually only apply to validators? 
    /// `contiguous_epochs_validating_and_mining`: the number of contiguous 
    ///     epochs the miner has been mining above threshold 
    ///     TODO does this actually only apply to validators?
    /// `epochs_since_last_account_creation`: the number of epochs since 
    ///     the miner last created a new account
    struct TowerProofHistory has key { // Todo: rename to TowerState ?
        previous_proof_hash: vector<u8>,
        verified_tower_height: u64, 
        latest_epoch_mining: u64,
        count_proofs_in_epoch: u64,
        epochs_validating_and_mining: u64,
        contiguous_epochs_validating_and_mining: u64,
        epochs_since_last_account_creation: u64
    }

    struct VDFDifficulty has key {

      // current epoch number of iterations (difficulty) of vdf
      difficulty: u64,
      // current epoch security parameter for VDF
      security: u64,
      // previous epoch's difficulty. Allowance for all validtors on first proof of epoch
      prev_diff: u64,
      // allowance for first proof.
      prev_sec: u64,
    }

    // Create the difficulty struct
    public fun init_difficulty(vm: &signer) {
      CoreAddresses::assert_diem_root(vm);
      if (!exists<VDFDifficulty>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        if (Testnet::is_testnet()) {
          move_to<VDFDifficulty>(vm, VDFDifficulty {
            difficulty: 100,
            security: 512,
            prev_diff: 100,
            prev_sec: 512,
          });
        } else {
          move_to<VDFDifficulty>(vm, VDFDifficulty {
            difficulty: 5000000,
            security: 512,
            prev_diff: 5000000,
            prev_sec: 512,
          });
        }

      }
    }


    /// Create an empty list of miners 
    fun init_miner_list(vm: &signer) {
      CoreAddresses::assert_diem_root(vm);
      move_to<TowerList>(vm, TowerList {
        list: Vector::empty<address>()
      }); 
    }
    
    /// Create an empty miner stats 
    public fun init_tower_counter(
      vm: &signer,
      lifetime_proofs: u64,
      lifetime_validator_proofs: u64,
      lifetime_fullnode_proofs: u64,
    ) {
      if (!exists<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        move_to<TowerCounter>(vm, TowerCounter {
          lifetime_proofs,
          lifetime_validator_proofs,
          lifetime_fullnode_proofs,
          proofs_in_epoch: 0,
          validator_proofs_in_epoch: 0,
          fullnode_proofs_in_epoch: 0,
          validator_proofs_in_epoch_above_thresh: 0,
          fullnode_proofs_in_epoch_above_thresh: 0,
        });
      }

    }

    /// Create empty miners list and stats
    public fun init_miner_list_and_stats(vm: &signer) {
      init_miner_list(vm);

      // Note: for testing migration we need to destroy this struct, see test_danger_destroy_tower_counter
      init_tower_counter(vm, 0, 0, 0); 
    }

    /// returns true if miner at `addr` has been initialized 
    public fun is_init(addr: address):bool {
      exists<TowerProofHistory>(addr)
    }

    /// is onboarding
    public fun is_onboarding(addr: address): bool acquires TowerProofHistory {
      let count = get_count_in_epoch(addr);
      let state = borrow_global<TowerProofHistory>(addr);

      count < 2 &&
      state.epochs_since_last_account_creation < 2
    }

    // Creates proof blob object from input parameters
    // Permissions: PUBLIC, ANYONE can call this function.
    public fun create_proof_blob(
      challenge: vector<u8>,
      solution: vector<u8>,
      difficulty: u64,
      security: u64,
    ): Proof {
       Proof {
         challenge,
         difficulty,
         solution,
         security,
      }
    }

    /// Private, can only be called within module
    /// adds `tower` to list of towers 
    fun increment_miners_list(miner: address) acquires TowerList {
      if (exists<TowerList>(@0x0)) {
        let state = borrow_global_mut<TowerList>(@0x0);
        if (!Vector::contains<address>(&mut state.list, &miner)) {
          Vector::push_back<address>(&mut state.list, miner);
        }
      }
    }

    // Helper function for genesis to process genesis proofs.
    // Permissions: PUBLIC, ONLY VM, AT GENESIS.
    public fun genesis_helper(
      vm_sig: &signer,
      miner_sig: &signer,
      challenge: vector<u8>,
      solution: vector<u8>,
      difficulty: u64,
      security: u64,
    ) acquires TowerProofHistory, TowerList, TowerCounter {
      // TODO: Previously in OLv3 is_genesis() returned true. 
      // How to check that this is part of genesis? is_genesis returns false here.

      // In rust the vm_genesis creates a Signer for the miner. 
      // So the SENDER is not the same and the Signer.

      init_miner_state(miner_sig, &challenge, &solution, difficulty, security);
      // TODO: Move this elsewhere? 
      // Initialize stats for first validator set from rust genesis. 
      let node_addr = Signer::address_of(miner_sig);
      Stats::init_address(vm_sig, node_addr);
    }

    /// This function is called to submit proofs to the chain 
    /// Function index: 01
    /// Permissions: PUBLIC, ANYONE
    public fun commit_state(
      miner_sign: &signer,
      proof: Proof
    ) acquires TowerProofHistory, TowerList, TowerCounter, VDFDifficulty {
      // Get address, assumes the sender is the signer.
      let miner_addr = Signer::address_of(miner_sign);
      let diff = borrow_global_mut<VDFDifficulty>(CoreAddresses::VM_RESERVED_ADDRESS());

      // This may be the 0th proof of an end user that hasn't had tower state initialized
      if (!is_init(miner_addr)) {
        
        assert(&proof.difficulty == &Globals::get_vdf_difficulty_baseline(), Errors::invalid_argument(130102));
        assert(&proof.security == &Globals::get_vdf_security_baseline(), Errors::invalid_argument(13010202));

        // check proof belongs to user.
        let (addr_in_proof, _) = VDF::extract_address_from_challenge(&proof.challenge);
        assert(addr_in_proof == Signer::address_of(miner_sign), Errors::requires_role(130112));

        init_miner_state(miner_sign, &proof.challenge, &proof.solution, proof.difficulty, proof.security);
        return
      };


      // Skip this check on local tests, we need tests to send different difficulties.
      if (!Testnet::is_testnet()){
        // Get vdf difficulty constant. Will be different in tests than in production.
        
        // need to also give allowance for user's first proof in epoch to be in the last proof.
        if (get_count_in_epoch(miner_addr) == 0) { 
          // first proof in this epoch, can be either the previous difficulty or the current one
          let is_diff = &proof.difficulty == &diff.difficulty ||
          &proof.difficulty == &diff.prev_diff;

          let is_sec = &proof.difficulty == &diff.security ||
          &proof.difficulty == &diff.prev_sec;

          assert(is_diff, Errors::invalid_argument(130102));
          assert(is_sec, Errors::invalid_argument(13010202));
        } else {
          assert(&proof.difficulty == &diff.difficulty, Errors::invalid_argument(130102));
          assert(&proof.security == &diff.security, Errors::invalid_argument(13010202));
        };
      };
      // Process the proof
      verify_and_update_state(miner_addr, proof, true);
    }

    // This function is called by the OPERATOR associated with node,
    // it verifies the proof and commits to chain.
    // Function index: 02
    // Permissions: PUBLIC, ANYONE
    public fun commit_state_by_operator(
      operator_sig: &signer,
      miner_addr: address,
      proof: Proof
    ) acquires TowerProofHistory, TowerList, TowerCounter {

      // Check the signer is in fact an operator delegated by the owner.
      
      // Get address, assumes the sender is the signer.
      assert(ValidatorConfig::get_operator(miner_addr) == Signer::address_of(operator_sig), Errors::requires_role(130103));
      // Abort if not initialized. Assumes the validator Owner account already has submitted the 0th miner proof in onboarding.
      assert(exists<TowerProofHistory>(miner_addr), Errors::not_published(130104));

      // Return early if difficulty and security are not correct.
      // Check vdf difficulty constant. Will be different in tests than in production.
      // Skip this check on local tests, we need tests to send differentdifficulties.
      if (!Testnet::is_testnet()){
        assert(&proof.difficulty == &Globals::get_vdf_difficulty_baseline(), Errors::invalid_argument(130105));
        assert(&proof.security == &Globals::get_vdf_difficulty_baseline(), Errors::invalid_state(130106));
      };
      
      // Process the proof
      verify_and_update_state(miner_addr, proof, true);
      
      // TODO: The operator mining needs its own struct to count mining.
      // For now it is implicit there is only 1 operator per validator, 
      // and that the fullnode state is the place to count.
      // This will require a breaking change to TowerState
      // FullnodeState::inc_proof_by_operator(operator_sig, miner_addr);
    }

    // Function to verify a proof blob and update a TowerProofHistory
    // Permissions: private function.
    // Function index: 03
    fun verify_and_update_state(
      miner_addr: address,
      proof: Proof,
      steady_state: bool
    ) acquires TowerProofHistory, TowerList, TowerCounter {
      // instead of looping through all miners at end of epcoh the stats are only reset when the miner submits a new proof.
      lazy_reset_count_in_epoch(miner_addr);

      assert(
        get_count_in_epoch(miner_addr) < Globals::get_epoch_mining_thres_upper(), 
        Errors::invalid_state(130108)
      );

      let miner_history = borrow_global<TowerProofHistory>(miner_addr);

      // If not genesis proof, check hash to ensure the proof continues the chain
      if (steady_state) {
        //If not genesis proof, check hash 
        assert(&proof.challenge == &miner_history.previous_proof_hash,
        Errors::invalid_state(130109));      
      };

      let valid = VDF::verify(&proof.challenge, &proof.solution, &proof.difficulty, &proof.security);
      assert(valid, Errors::invalid_argument(130110));

      // add the miner to the miner list if not present
      increment_miners_list(miner_addr);

      // Get a mutable ref to the current state
      let miner_history = borrow_global_mut<TowerProofHistory>(miner_addr);

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

      increment_stats(miner_addr);
    }

    // Checks that the validator has been mining above the count threshold
    // Note: this is only called on a validator successfully meeting 
    // the validation thresholds (different than mining threshold). 
    // So the function presumes the validator is in good standing for that epoch.
    // Permissions: private function
    // Function index: 04
    fun update_epoch_metrics_vals(account: &signer, miner_addr: address) acquires TowerProofHistory {
      // The goal of update_metrics is to confirm that a miner participated in consensus during
      // an epoch, but also that there were mining proofs submitted in that epoch.
      CoreAddresses::assert_diem_root(account);

      // Tower may not have been initialized. 
      // Simply return in this case (don't abort)
      if(!is_init(miner_addr)) { return };

      // Check that there was mining and validating in period.
      // Account may not have any proofs submitted in epoch, since 
      // the resource was last emptied.
      let passed = node_above_thresh(miner_addr);
      let miner_history = borrow_global_mut<TowerProofHistory>(miner_addr);
      // Update statistics.
      if (passed) {
          // let this_epoch = DiemConfig::get_current_epoch();
          // miner_history.latest_epoch_mining = this_epoch; // TODO: Don't need this
          miner_history.epochs_validating_and_mining 
            = miner_history.epochs_validating_and_mining + 1u64;
          miner_history.contiguous_epochs_validating_and_mining 
            = miner_history.contiguous_epochs_validating_and_mining + 1u64;
          miner_history.epochs_since_last_account_creation 
            = miner_history.epochs_since_last_account_creation + 1u64;
      } else {
        // didn't meet the threshold, reset this count
        miner_history.contiguous_epochs_validating_and_mining = 0;
      };

      // This is the end of the epoch, reset the count of proofs
      miner_history.count_proofs_in_epoch = 0u64;
    }

    /// Checks to see if miner submitted enough proofs to be considered compliant
    public fun node_above_thresh(miner_addr: address): bool acquires TowerProofHistory {
      get_count_in_epoch(miner_addr) >= Globals::get_epoch_mining_thres_lower()
    }

    fun epoch_param_reset(vm: &signer) acquires VDFDifficulty, TowerList, TowerProofHistory  {
      CoreAddresses::assert_diem_root(vm);

      let diff = borrow_global_mut<VDFDifficulty>(CoreAddresses::VM_RESERVED_ADDRESS());

      diff.prev_diff = diff.difficulty;
      diff.prev_sec = diff.security;
      
      // NOTE: For now we are not changing the vdf security params.
      if (Testnet::is_testnet()) {
        // VDF proofs must be even numbers.
        let rng =  toy_rng(3, 2);
        if (rng > 0) {
          rng = rng * 2;
        };
        diff.difficulty = Globals::get_vdf_difficulty_baseline() + rng;
       
      }
    }

    // Used at epoch boundary by vm to reset all validator's statistics.
    // Permissions: PUBLIC, ONLY VM.
    public fun reconfig(vm: &signer, outgoing_validators: &vector<address>) acquires TowerProofHistory, TowerList, TowerCounter, VDFDifficulty {
      // Check permissions
      CoreAddresses::assert_diem_root(vm);

      // update the vdf parameters
      epoch_param_reset(vm);

      // Iterate through validators and call update_metrics for each validator that had proofs this epoch
      let vals_len = Vector::length<address>(outgoing_validators); //TODO: These references are weird
      let i = 0;
      while (i < vals_len) {
          let val = Vector::borrow(outgoing_validators, i); 

          // For testing: don't call update_metrics unless there is account state for the address.
          if (exists<TowerProofHistory>(*val)){
              update_epoch_metrics_vals(vm, *val);
          };
          i = i + 1;
      };

      epoch_reset(vm);
      // safety
      if (exists<TowerList>(@0x0)) {
        //reset miner list
        let towerlist_state = borrow_global_mut<TowerList>(@0x0);
        towerlist_state.list = Vector::empty<address>();
      };
    }

    // Function to initialize miner state
    // Permissions: PUBLIC, Signer, Validator only
    // Function code: 07
    public fun init_miner_state(
      miner_sig: &signer,
      challenge: &vector<u8>,
      solution: &vector<u8>,
      difficulty: u64,
      security: u64
    ) acquires TowerProofHistory, TowerList, TowerCounter {
      
      // NOTE Only Signer can update own state.
      // Should only happen once.
      assert(!exists<TowerProofHistory>(Signer::address_of(miner_sig)), Errors::requires_role(130111));
      // DiemAccount calls this.
      // Exception is DiemAccount which can simulate a Signer.
      // Initialize TowerProofHistory object and give to miner account
      move_to<TowerProofHistory>(miner_sig, TowerProofHistory{
        previous_proof_hash: Vector::empty(),
        verified_tower_height: 0u64,
        latest_epoch_mining: 0u64,
        count_proofs_in_epoch: 1u64,
        epochs_validating_and_mining: 0u64,
        contiguous_epochs_validating_and_mining: 0u64,
        epochs_since_last_account_creation: 0u64,
      });
      // create the initial proof submission
      let proof = Proof {
        challenge: *challenge,
        difficulty,  
        solution: *solution,
        security,
      };

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
      assert(Vector::length(challenge) >= 32, Errors::invalid_argument(130113));
      let (parsed_address, _auth_key) = VDF::extract_address_from_challenge(challenge);
      // Confirm the address is corect and included in challenge
      assert(new_account_address == parsed_address, Errors::requires_address(130114));
    }

    // Get latest epoch mined by node on given address
    // Permissions: public ony VM can call this function.
    // Function code: 09
    public fun get_miner_latest_epoch(addr: address): u64 acquires TowerProofHistory {
      let addr_state = borrow_global<TowerProofHistory>(addr);
      *&addr_state.latest_epoch_mining
    }

    // Function to reset the timer for when an account can be created 
    // must be signed by the account being reset 
    // done as a part of the creation of new accounts. 
    public fun reset_rate_limit(miner: &signer) acquires TowerProofHistory {
      let state = borrow_global_mut<TowerProofHistory>(Signer::address_of(miner));
      state.epochs_since_last_account_creation = 0;
    }

    fun increment_stats(miner_addr: address) acquires TowerProofHistory, TowerCounter {
      // safety. Don't cause VM to halt
      if (!exists<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS())) return;

      let above = node_above_thresh(miner_addr);

      let state = borrow_global_mut<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());

      if (ValidatorConfig::is_valid(miner_addr)) {
        state.validator_proofs_in_epoch = state.validator_proofs_in_epoch + 1;
        state.lifetime_validator_proofs = state.lifetime_validator_proofs + 1;
        // only proofs above threshold are counted here. The preceding proofs are not counted;
        if (above) { state.validator_proofs_in_epoch_above_thresh = state.validator_proofs_in_epoch_above_thresh + 1; }
      } else {
        state.fullnode_proofs_in_epoch = state.fullnode_proofs_in_epoch + 1;
        state.lifetime_fullnode_proofs = state.lifetime_fullnode_proofs + 1;
        // Preceding proofs before threshold was met are not counted to payment.
        if (above) { state.fullnode_proofs_in_epoch_above_thresh = state.fullnode_proofs_in_epoch_above_thresh + 1; }
      };
      
      state.proofs_in_epoch = state.proofs_in_epoch + 1;
      state.lifetime_proofs = state.lifetime_proofs + 1;
    }

    /// Reset the tower counter at the end of epoch.
    public fun epoch_reset(vm: &signer) acquires TowerCounter {
      CoreAddresses::assert_vm(vm);
      if (!exists<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS())) return;

      let state = borrow_global_mut<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());
      state.proofs_in_epoch = 0;
      state.validator_proofs_in_epoch = 0;
      state.fullnode_proofs_in_epoch = 0;
      state.validator_proofs_in_epoch_above_thresh = 0;
      state.fullnode_proofs_in_epoch_above_thresh = 0;
    }

    //////////////////////
    //  Experimental  //
    /////////////////////


    // EXPERIMENTAL: this is a test to see if we can get a plausible RNG from the VDF proofs, to use in low-stakes scenarios.
    // THIS IS AN EXPERIMENT, IT WILL BREAK. DON'T USE FOR ANYTHING SERIOUS.
    // We want to see where it breaks.
    // the first use case is to change the VDF difficulty parameter by tiny margins, in order to make it difficult to stockpile VDFs in a previous epoch, but not change the security properties.
    // the goal is to push all the RNG work to all the tower miners in the network, and minimize compute on the Move side
    use 0x1::Debug::print;

    public fun toy_rng(seed: u64, iters: u64): u64 acquires TowerList, TowerProofHistory {
      // Get the list of all miners L
      // Pick a tower miner  (M) from the seed position 1/(N) of the list of miners.
      print(&77777777);

      let l = get_miner_list();
      print(&l);
      // the length will keep incrementing through the epoch. The last miner can know what the starting position will be. There could be a race to be the last validator to augment the set and bias the initial shuffle.
      let len = Vector::length(&l);
      if (len == 0) return 0;
      print(&5555);

      // start n with the seed index
      let n = seed;

      let i = 0;
      while (i < iters) {
        print(&6666);
        print(&i);
        // make sure we get an n smaller than list of validators
        // abort if loops too much
        let k = 0;
        while (n > len) {
          if (k > 1000) return 0;
          n = n / len;
          k = k + 1;
        };
        print(&n);
        print(&len);
        // double check
        if (len <= n) return 0;

        print(&666602);
        let miner_addr = Vector::borrow<address>(&l, n);
  
        print(&666603);
        let vec = if (exists<TowerProofHistory>(*miner_addr)) {
          *&borrow_global<TowerProofHistory>(*miner_addr).previous_proof_hash
        } else { return 0 };

        print(&vec);

        print(&666604);
        // take the last bit (B) from their last proof hash.

        n = (Vector::pop_back(&mut vec) as u64);
        print(&666605);
        i = i + 1;
      };
      print(&8888);

      n
    }


    //////////////////////
    ///    Getters     ///
    /////////////////////

    // Returns number of epochs for input miner's state
    // Permissions: PUBLIC, ANYONE
    // TODO: Rename
    public fun get_miner_list(): vector<address> acquires TowerList {
      if (!exists<TowerList>(@0x0)) {
        return Vector::empty<address>()  
      };
      *&borrow_global<TowerList>(@0x0).list
    }

    // Returns number of epochs for input miner's state
    // Permissions: PUBLIC, ANYONE
    // TODO: Rename
    public fun get_tower_height(node_addr: address): u64 acquires TowerProofHistory {
      if (exists<TowerProofHistory>(node_addr)) {
        return borrow_global<TowerProofHistory>(node_addr).verified_tower_height
      };
      0
    }

    // Returns number of epochs user successfully mined AND validated
    // Permissions: PUBLIC, ANYONE
    // TODO: Rename
    public fun get_epochs_compliant(node_addr: address): u64 acquires TowerProofHistory {
      if (exists<TowerProofHistory>(node_addr)) {
        return borrow_global<TowerProofHistory>(node_addr).epochs_validating_and_mining
      };
      0
    }

    // returns the number of proofs for a miner in the current epoch
    public fun get_count_in_epoch(miner_addr: address): u64 acquires TowerProofHistory {
      if (exists<TowerProofHistory>(miner_addr)) {
        let s = borrow_global<TowerProofHistory>(miner_addr);
        if (s.latest_epoch_mining == DiemConfig::get_current_epoch()) {
          return s.count_proofs_in_epoch
        };
      };
      0
    }

    // returns the number of proofs for a miner in the current epoch in EXCESS Of the the threshold
    public fun get_count_above_thresh_in_epoch(miner_addr: address): u64 acquires TowerProofHistory {
      if (exists<TowerProofHistory>(miner_addr)) {
        if (borrow_global<TowerProofHistory>(miner_addr).count_proofs_in_epoch > Globals::get_epoch_mining_thres_lower()) {
          return borrow_global<TowerProofHistory>(miner_addr).count_proofs_in_epoch - Globals::get_epoch_mining_thres_lower()
        }
      };
      0
    }
    // lazily reset proofs_in_epoch intead of looping through list.
    // danger: this is a private function. Do not make public.
    fun lazy_reset_count_in_epoch(miner_addr: address) acquires TowerProofHistory {
      let s = borrow_global_mut<TowerProofHistory>(miner_addr);
      if (s.latest_epoch_mining < DiemConfig::get_current_epoch()) {
        s.count_proofs_in_epoch = 0;
      };
    }

    // Returns if the miner is above the account creation rate-limit
    // Permissions: PUBLIC, ANYONE
    public fun can_create_val_account(node_addr: address): bool acquires TowerProofHistory {
      if(Testnet::is_testnet() || StagingNet::is_staging_net()) return true;
      // check if rate limited, needs 7 epochs of validating.
      if (exists<TowerProofHistory>(node_addr)) { 
        return 
          borrow_global<TowerProofHistory>(node_addr).epochs_since_last_account_creation 
          >= EPOCHS_UNTIL_ACCOUNT_CREATION
      };
      false 
    }

    public fun get_validator_proofs_in_epoch(): u64 acquires TowerCounter{
      let state = borrow_global<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());
      state.validator_proofs_in_epoch
    }

    public fun get_fullnode_proofs_in_epoch(): u64 acquires TowerCounter{
      let state = borrow_global<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());
      state.fullnode_proofs_in_epoch
    }

    public fun get_fullnode_proofs_in_epoch_above_thresh(): u64 acquires TowerCounter{
      let state = borrow_global<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());
      state.fullnode_proofs_in_epoch_above_thresh
    }

    public fun get_lifetime_proof_count(): (u64, u64, u64) acquires TowerCounter{
      let s = borrow_global<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());
      (s.lifetime_proofs, s.lifetime_validator_proofs, s.lifetime_fullnode_proofs)
    }

    public fun danger_migrate_get_lifetime_proof_count(): (u64, u64, u64) acquires TowerStats{
      if (exists<TowerStats>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        let s = borrow_global<TowerStats>(CoreAddresses::VM_RESERVED_ADDRESS());
        return (s.proofs_in_epoch, s.validator_proofs, s.fullnode_proofs)
      };
      (0,0,0)
    }

    public fun get_difficulty(): (u64, u64) acquires VDFDifficulty {
      if (exists<VDFDifficulty>(CoreAddresses::VM_RESERVED_ADDRESS())) {
        let v = borrow_global_mut<VDFDifficulty>(CoreAddresses::VM_RESERVED_ADDRESS());
        return (v.difficulty, v.security)
      } else {
        // we are probably in the middle of a migration
        (5000000, 512)
      }
    }


    //////////////////
    // TEST HELPERS //
    //////////////////

    // Initiates a miner for a testnet
    // Function index: 10
    // Permissions: PUBLIC, SIGNER, TEST ONLY
    public fun test_helper_init_val(
        miner_sig: &signer,
        challenge: vector<u8>,
        solution: vector<u8>,
        difficulty: u64,
        security: u64,
      ) acquires TowerProofHistory, TowerList, TowerCounter {
        assert(Testnet::is_testnet(), 130102014010);

        move_to<TowerProofHistory>(miner_sig, TowerProofHistory {
          previous_proof_hash: Vector::empty(),
          verified_tower_height: 0u64,
          latest_epoch_mining: 0u64,
          count_proofs_in_epoch: 0u64,
          epochs_validating_and_mining: 1u64,
          contiguous_epochs_validating_and_mining: 0u64,
          epochs_since_last_account_creation: 10u64, // is not rate-limited
        });

        // Needs difficulty to test between easy and hard mode.
        let proof = Proof {
          challenge,
          difficulty,
          solution,
          security,
        };

        verify_and_update_state(Signer::address_of(miner_sig), proof, false);
        // FullnodeState::init(miner_sig);
    }

    // Note: Used only in tests
    public fun test_epoch_reset_counter(vm: &signer) acquires TowerCounter {
      assert(Testnet::is_testnet(), Errors::invalid_state(130118));
      CoreAddresses::assert_vm(vm);
      let state = borrow_global_mut<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());
      state.lifetime_proofs = 0;
      state.lifetime_validator_proofs = 0;
      state.lifetime_fullnode_proofs = 0;
      state.proofs_in_epoch = 0;
      state.validator_proofs_in_epoch = 0;
      state.fullnode_proofs_in_epoch = 0;
      state.validator_proofs_in_epoch_above_thresh = 0;
      state.fullnode_proofs_in_epoch_above_thresh = 0;
    }

    // Function index: 11
    // provides a different method to submit from the operator for use in tests 
    // where the operator cannot sign a transaction
    // Permissions: PUBLIC, SIGNER, TEST ONLY
    public fun test_helper_operator_submits(
      operator_addr: address, // Testrunner does not allow arbitrary accounts 
                              // to submit txs, need to use address, so this will 
                              // differ slightly from api
      miner_addr: address,
      proof: Proof
    ) acquires TowerProofHistory, TowerList, TowerCounter {
      assert(Testnet::is_testnet(), 130102014010);
      
      // Get address, assumes the sender is the signer.
      assert(
        ValidatorConfig::get_operator(miner_addr) == operator_addr,
        Errors::requires_address(130111)
      );
      // Abort if not initialized.
      assert(exists<TowerProofHistory>(miner_addr), Errors::not_published(130116));

      // Check vdf difficulty constant. Will be different in tests than in production.
      // Skip this check on local tests, we need tests to send different difficulties.
      if (!Testnet::is_testnet()){ // todo: remove?
        assert(&proof.difficulty == &Globals::get_vdf_difficulty_baseline(), Errors::invalid_state(130117));
      };

      verify_and_update_state(miner_addr, proof, true);
      
      // TODO: The operator mining needs its own struct to count mining.
      // For now it is implicit there is only 1 operator per validator,
      // and that the fullnode state is the place to count.
      // This will require a breaking change to TowerState
      // FullnodeState::inc_proof_by_operator(operator_sig, miner_addr);
    }

    // Function code: 12
    // Use in testing to mock mining without producing proofs
    public fun test_helper_mock_mining(sender: &signer,  count: u64) acquires TowerProofHistory, TowerCounter {
      assert(Testnet::is_testnet(), Errors::invalid_state(130118));
      let addr = Signer::address_of(sender);
      danger_mock_mining(addr, count)
    }

    // Function code: 13
    // mocks mining for an arbitrary account from the vm 
    public fun test_helper_mock_mining_vm(vm: &signer, addr: address, count: u64) acquires TowerProofHistory, TowerCounter {
      assert(Testnet::is_testnet(), Errors::invalid_state(130120));
      CoreAddresses::assert_diem_root(vm);
      danger_mock_mining(addr, count)
    }

    fun danger_mock_mining(addr: address, count: u64) acquires TowerProofHistory, TowerCounter {
      // again for safety
      assert(Testnet::is_testnet(), Errors::invalid_state(130118));


      let i = 0;
      while (i < count) {
        increment_stats(addr);
        let state = borrow_global_mut<TowerProofHistory>(addr);
        // mock verify_and_update
        state.verified_tower_height = state.verified_tower_height + 1;
        state.count_proofs_in_epoch = state.count_proofs_in_epoch + 1;
        i = i + 1;
      };

      let state = borrow_global_mut<TowerProofHistory>(addr);
      state.count_proofs_in_epoch = count;
      state.latest_epoch_mining = DiemConfig::get_current_epoch();
    }



    // Permissions: PUBLIC, VM, TESTING 
    // Get the vm to trigger a reconfig for testing
    // Function code: 14
    public fun test_helper_mock_reconfig(account: &signer, miner_addr: address) acquires TowerProofHistory, TowerCounter {
      CoreAddresses::assert_diem_root(account);
      assert(Testnet::is_testnet(), Errors::invalid_state(130122));
      // update_metrics(account, miner_addr);
      epoch_reset(account);
      update_epoch_metrics_vals(account, miner_addr);
    }

    // Get weight of validator identified by address
    // Permissions: PUBLIC, ANYONE, TESTING 
    // Function code: 15
    public fun test_helper_get_height(miner_addr: address): u64 acquires TowerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130123));
      assert(exists<TowerProofHistory>(miner_addr), Errors::not_published(130124));

      let state = borrow_global<TowerProofHistory>(miner_addr);
      *&state.verified_tower_height
    }

    // TODO: remove this and replace tests with get_count_in_epoch
    public fun test_helper_get_count(account: &signer): u64 acquires TowerProofHistory {
        assert(Testnet::is_testnet(), 130115014011);
        let addr = Signer::address_of(account);
        get_count_in_epoch(addr)
    }

    public fun test_helper_get_nominal_count(miner_addr: address): u64 acquires TowerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130123));
      assert(exists<TowerProofHistory>(miner_addr), Errors::not_published(130124));

      let state = borrow_global<TowerProofHistory>(miner_addr);
      *&state.count_proofs_in_epoch
    }

    // Function code: 16
    public fun test_helper_get_contiguous_vm(vm: &signer, miner_addr: address): u64 acquires TowerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130125));
      CoreAddresses::assert_diem_root(vm);
      borrow_global<TowerProofHistory>(miner_addr).contiguous_epochs_validating_and_mining
    }

    // Function code: 17
    // Sets the epochs since last account creation variable to allow `account`
    // to create a new account
    public fun test_helper_set_rate_limit(account: &signer, value: u64) acquires TowerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130126));
      let addr = Signer::address_of(account);
      let state = borrow_global_mut<TowerProofHistory>(addr);
      state.epochs_since_last_account_creation = value;
    }

    public fun test_helper_set_epochs_mining(node_addr: address, value: u64) acquires TowerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130126));

      let s = borrow_global_mut<TowerProofHistory>(node_addr);
      s.epochs_validating_and_mining = value;
    }

    public fun test_helper_set_proofs_in_epoch(node_addr: address, value: u64) acquires TowerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130126));

      let s = borrow_global_mut<TowerProofHistory>(node_addr);
      s.count_proofs_in_epoch = value;
    }

    // Function code: 18
    // returns the previous proof hash for `account`
    public fun test_helper_previous_proof_hash(
      account: &signer
    ): vector<u8> acquires TowerProofHistory {
      assert(Testnet::is_testnet()== true, Errors::invalid_state(130128));
      let addr = Signer::address_of(account);
      *&borrow_global<TowerProofHistory>(addr).previous_proof_hash
    }

    public fun test_helper_set_weight_vm(vm: &signer, addr: address, weight: u64) acquires TowerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130113));
      CoreAddresses::assert_diem_root(vm);
      let state = borrow_global_mut<TowerProofHistory>(addr);
      state.verified_tower_height = weight;
    }

    public fun test_helper_set_weight(account: &signer, weight: u64) acquires TowerProofHistory {
      assert(Testnet::is_testnet(), Errors::invalid_state(130113));
      let addr = Signer::address_of(account);
      let state = borrow_global_mut<TowerProofHistory>(addr);
      state.verified_tower_height = weight;
    }

    public fun test_mock_depr_tower_stats(vm: &signer) {
      assert(Testnet::is_testnet(), Errors::invalid_state(130113));
      CoreAddresses::assert_vm(vm);
      move_to<TowerStats>(vm, TowerStats{
        proofs_in_epoch: 111,
        validator_proofs: 222,
        fullnode_proofs: 333,
      });
    }

    public fun test_get_liftime_proofs(): u64 acquires TowerCounter {
      assert(Testnet::is_testnet(), Errors::invalid_state(130113));
      
      let s = borrow_global<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());
      s.lifetime_proofs
    }

    public fun test_set_vdf_difficulty(vm: &signer, diff: u64, sec: u64) acquires VDFDifficulty {
      assert(Testnet::is_testnet(), Errors::invalid_state(130113));
      CoreAddresses::assert_vm(vm);
      
      let s = borrow_global_mut<VDFDifficulty>(CoreAddresses::VM_RESERVED_ADDRESS());
      s.difficulty = diff;
      s.security = sec;
    }

    public fun test_danger_destroy_tower_counter(vm: &signer) acquires TowerCounter {
      assert(Testnet::is_testnet(), Errors::invalid_state(130113));
      CoreAddresses::assert_vm(vm);
      assert(exists<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS()), Errors::invalid_state(130115));
        
        // We destroy the data resource for sender
        // move_from and then destructure

        let TowerCounter {
          lifetime_proofs: _,
          lifetime_validator_proofs: _,
          lifetime_fullnode_proofs: _,
          proofs_in_epoch: _,
          validator_proofs_in_epoch: _,
          fullnode_proofs_in_epoch: _,
          validator_proofs_in_epoch_above_thresh: _,
          fullnode_proofs_in_epoch_above_thresh: _,
       } = move_from<TowerCounter>(CoreAddresses::VM_RESERVED_ADDRESS());
    }
}
}


