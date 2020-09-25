///////////////////////////////////////////////////////////////////
// 0L Module
// MinerState
///////////////////////////////////////////////////////////////////

address 0x0 {
  module MinerState {
    use 0x0::VDF;
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::ValidatorUniverse;
    use 0x0::Signer;
    use 0x0::LibraConfig;
    use 0x0::Globals;
    use 0x0::Hash;
    use 0x0::LibraTimestamp;
    // use 0x0::Debug;
    use 0x0::Testnet;

    // Struct to store information about a VDF proof submitted
    struct VdfProofBlob {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
        epoch: u64,
    }

    // Struct to encapsulate information about the state of a miner
    resource struct MinerProofHistory {
      // TODO: this doesn't need to be a vector, it gets cleared.
        verified_proof_history: vector<vector<u8>>,
        invalid_proof_history: vector<vector<u8>>,
        verified_tower_height: u64, // user's latest verified_tower_height
        latest_epoch_mining: u64,
        count_proofs_in_epoch: u64,
        epochs_validating_and_mining: u64,
        contiguous_epochs_validating_and_mining: u64,
    }

    // Creates proof blob object from input parameters
    // Permissions: PUBLIC, ANYONE can call this function.
    public fun create_proof_blob(
      challenge: vector<u8>,
      difficulty: u64,
      solution: vector<u8>,
    ) : VdfProofBlob {
       let epoch = LibraConfig::get_current_epoch();
       VdfProofBlob {
         challenge,
         difficulty,
         solution,
         epoch
      }
    }

    // Helper function for genesis to process genesis proofs.
    // Permissions: PUBLIC, ONLY VM, AT GENESIS.
    public fun genesis_helper (
      miner: &signer,
      challenge: vector<u8>,
      solution: vector<u8>
    ) acquires MinerProofHistory {

      Transaction::assert(Transaction::sender()
 == 0x0, 130102014010);

      Transaction::assert(LibraTimestamp::is_genesis(), 130102024010);

      let difficulty = Globals::get_difficulty();
      let vdf_proof_blob = VdfProofBlob {
        challenge,
        difficulty,  
        solution,
        epoch: 0,
      };
      commit_state(miner, vdf_proof_blob)
    }


    // This function verifies the proof and commits to chain.
    // Permissions: PUBLIC, ANYONE
    public fun commit_state(sender: &signer, vdf_proof_blob: VdfProofBlob) acquires MinerProofHistory {

      //NOTE: Does not check that the sender is the miner. This is necessary for the Onboarding transaction.

      // Get address
      let miner_addr = Signer::address_of(sender);
      // Get vdf difficulty constant. Will be different in tests than in production.
      let difficulty_constant = Globals::get_difficulty();

      // skip this check on test-net, we need tests to send different difficulties.
      if (!Testnet::is_testnet()){
        Transaction::assert(&vdf_proof_blob.difficulty == &difficulty_constant, 130106011010);
      };

      // This is the Onboarding case (miner not yet initialized):
      // Check if the miner's state is initialized.
      // Insert a new VdfProofBlob into a temp storage while saving all of miner's proofs to the miner's own address, including the first proof sent by someone else.
      // This may be the first time the miner is redeeming. If so, both resources are uninitialized. Initialize them
      if (! ::exists<MinerProofHistory>(miner_addr)) {
        // Verify the proof before anything else (i.e. user actually did the delay)
        // TODO: Find a faster way to check for miner tx errors, since it's an expensive operation.
        let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
        Transaction::assert(valid, 130106021021);

        // Initialize the miner state for the new miner
        init_miner_state(sender);
        // Verify the blob and update the newly initialized state
        verify_and_update_state(miner_addr,vdf_proof_blob , false );

      } else {
        //  This is the steady-state path (miner has already been initialized)
        // Check to ensure the transaction sender is indeed the miner
        Transaction::assert(Transaction::sender() == miner_addr, 130106031010);
        // Verify the blob and update the state.
        verify_and_update_state(miner_addr,vdf_proof_blob, true  );
      }
    }

    // Function to verify a proof blob and update a MinerProofHistory
    // Permissions: private function.
    fun verify_and_update_state(
      miner_addr: address,
      vdf_proof_blob: VdfProofBlob,
      initialized_miner: bool
    ) acquires MinerProofHistory {
      // Get a mutable ref to the current state
      let miner_redemption_state = borrow_global_mut<MinerProofHistory>(miner_addr);

      // If miner has already been initialized (i.e. not block_0)
      if (initialized_miner) {
        // TODO: 3. Add redeem attempt to invalid_proof_history, which will later be removed with successful verification.
        // TODO: Could also surface to client since ClientProxy for submit redeem tx is async.
        (miner_redemption_state, vdf_proof_blob) = check_hash_and_verify(miner_redemption_state, vdf_proof_blob);

      };
      miner_redemption_state.verified_proof_history = Vector::empty();
      Vector::push_back(&mut miner_redemption_state.verified_proof_history, Hash::sha3_256(*&vdf_proof_blob.solution));
      Transaction::assert(Vector::length(&miner_redemption_state.verified_proof_history) > 0, 130107021010);

      // Increment the verified_tower_height
      if (initialized_miner) {
        miner_redemption_state.verified_tower_height = miner_redemption_state.verified_tower_height + 1;
      } else {
        miner_redemption_state.verified_tower_height = 0;
        miner_redemption_state.count_proofs_in_epoch = 1
      };
      

      // NOTE: this is used by end_redeem
      miner_redemption_state.latest_epoch_mining = LibraConfig::get_current_epoch();
      // Debug::print(&0x000000000013370010005);

      // Prepare list of proofs in epoch for end of epoch statistics
      miner_redemption_state.count_proofs_in_epoch = miner_redemption_state.count_proofs_in_epoch + 1;

      // A single proof is sufficient to include an address as a candidate for validation, i.e. added to Validator Universe.

      ValidatorUniverse::add_validator( miner_addr );
    }


    // Helper function which checks if proof has already been submitted and verifies that proof is valid.
    // Permissions: private function.
    fun check_hash_and_verify(
      miner_redemption_state: &mut MinerProofHistory,
      vdf_proof_blob: VdfProofBlob): (&mut MinerProofHistory, VdfProofBlob) {

      let previous_verified_solution_hash = Vector::borrow(&miner_redemption_state.verified_proof_history, 0);

      Transaction::assert(&vdf_proof_blob.challenge == previous_verified_solution_hash, 130108031010);

      // Verify proof is valid
      let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid, 130108041021);

      (miner_redemption_state, vdf_proof_blob)
    }


    // Checks that the validator has been mining above the count threshold
    // Note: this is only called on a validator successfully meeting the validation thresholds (different than mining threshold). So the function presumes the validator is in good standing for that epoch.
    // Permissions: private function
    fun update_metrics(miner_addr: address) acquires MinerProofHistory {
      // The goal of end_redeem is to confirm that a miner participated in consensus during
      // an epoch, but also that there were mining proofs submitted in that epoch.

      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0, 130109014010);

      // Miner may not have been initialized. Simply return in this case (don't abort)
      if( ! ::exists<MinerProofHistory>( miner_addr ) ){
        return
      };

      // Check that there was mining and validating in period.
      // Account may not have any proofs submitted in epoch, since the resource was last emptied.

      let miner_redemption_state= borrow_global_mut<MinerProofHistory>(miner_addr);
      // Update statistics.
      if (miner_redemption_state.count_proofs_in_epoch > Globals::get_threshold()) {
          let this_epoch = LibraConfig::get_current_epoch();
          miner_redemption_state.latest_epoch_mining = this_epoch;
          miner_redemption_state.epochs_validating_and_mining = miner_redemption_state.epochs_validating_and_mining + 1u64;
          miner_redemption_state.contiguous_epochs_validating_and_mining = miner_redemption_state.contiguous_epochs_validating_and_mining + 1u64;
      };

      // This is the end of the epoch, reset the count of proofs
      miner_redemption_state.count_proofs_in_epoch = 0u64;
    }

    // Get weight of validator identified by address
    // Permissions: public, only VM can call this function.
    public fun get_validator_weight(miner_addr: address): u64 acquires MinerProofHistory {
      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0, 130110014010);

      // Miner may not have been initialized. (don't abort, just return 0)
      if( ! ::exists<MinerProofHistory>( miner_addr ) ){
        return 0
      };

      // Update the statistics.
      let miner_redemption_state= borrow_global_mut<MinerProofHistory>(miner_addr);
      let this_epoch = LibraConfig::get_current_epoch();
      miner_redemption_state.latest_epoch_mining = this_epoch;

      // Return its weight
      miner_redemption_state.epochs_validating_and_mining
    }

    // Bulk update the end_redeem state with the vector of validators from current epoch.
    // Permissions: PUBLIC, ONLY VM.
    public fun end_redeem_validator_universe(account: &signer)
                  acquires MinerProofHistory {
      // Check permissions
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 130111014010);

      // Get list of validators from ValidatorUniverse
      let eligible_validators = ValidatorUniverse::get_eligible_validators(account);

      // Iterate through validators and call redeem for each validator
      // that had proofs this epoch
      let size = Vector::length<address>(&eligible_validators);
      let i = 0;
      while (i < size) {
          let redeemed_addr = *Vector::borrow(&eligible_validators, i);

          // For testing: don't call end_redeem unless there is account state for the address.
          if ( ::exists<MinerProofHistory>( redeemed_addr ) ){
              update_metrics(redeemed_addr);
          };
          i = i + 1;
      };
    }


    // Function to initialize miner state
    // Permissions: private function.
    fun init_miner_state(miner: &signer){
      // Initialize MinerProofHistory object and give to miner account
      move_to<MinerProofHistory>(miner, MinerProofHistory{
        verified_proof_history: Vector::empty(),
        invalid_proof_history: Vector::empty(),
        verified_tower_height: 0u64,
        latest_epoch_mining: 0u64,
        count_proofs_in_epoch: 0u64,
        epochs_validating_and_mining: 0u64,
        contiguous_epochs_validating_and_mining: 0u64,
      });
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
      Transaction::assert(Vector::length(challenge) >= 32, 130113011000);
      let (parsed_address, _auth_key) = VDF::extract_address_from_challenge(challenge);
      // Confirm the address is corect and included in challenge
      Transaction::assert(new_account_address == parsed_address, 130113021010);

    }

    // Get weight of validator identified by address
    // Permissions: PUBLIC, ANYONE (from miner client for tx purposes).
    public fun get_miner_state(miner_addr: address): vector<vector<u8>> acquires MinerProofHistory {
      let test = borrow_global<MinerProofHistory>(miner_addr);
      *&test.verified_proof_history
    }

    // Get latest epoch mined by node on given address
    // Permissions: public ony VM can call this function.
    public fun get_miner_latest_epoch(addr: address): u64 acquires MinerProofHistory {
      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0, 130114014010);
      let addr_state = borrow_global<MinerProofHistory>(addr);
      *&addr_state.latest_epoch_mining
    }

    // Returns tower height from input miner's state
    // Permissions: public, TESTING only. The miner can get own info.
    public fun test_helper_get_miner_tower_height(miner_addr: address): u64 acquires MinerProofHistory {
      // let sender = Signer::address_of(Transaction::sender());
      Transaction::assert(Transaction::sender() == miner_addr, 130115014012);
      Transaction::assert(Testnet::is_testnet()
 == true, 130115014011);

      borrow_global<MinerProofHistory>(miner_addr).verified_tower_height
    }

    // TODO: Unused. Possibly useful for proof-of-weight calcs 
    // Permissions: public, VM only.
    // public fun get_count_proofs_in_epoch(miner_addr: address): u64 acquires MinerProofHistory {
    //   let sender = Transaction::sender();
    //   Transaction::assert(sender == 0x0, 130116014010);
    //    borrow_global<MinerProofHistory>(miner_addr).count_proofs_in_epoch
    // }

    // Returns number of epochs for input miner's state
    // Permissions: public, VM only, TESTING only
    public fun test_helper_get_miner_epochs(miner_addr: address): u64 acquires MinerProofHistory {
      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0, 130117014010);
      Transaction::assert(Testnet::is_testnet()
 == true, 130115014011);
      borrow_global<MinerProofHistory>(miner_addr).epochs_validating_and_mining
    }
  }
}


