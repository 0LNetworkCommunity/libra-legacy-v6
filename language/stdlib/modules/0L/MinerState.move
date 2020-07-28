address 0x0 {


  // Note: This module needs a key-value store.
  module MinerState {
    use 0x0::VDF;
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::ValidatorUniverse;
    use 0x0::Signer;
    use 0x0::LibraConfig;
    use 0x0::Globals;
    use 0x0::Hash;

    // Struct to store information about a VDF proof submitted
    struct VdfProofBlob {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
        reported_tower_height: u64,
        epoch: u64,
    }

    // Struct to encapsulate information about the state of a miner
    resource struct MinerProofHistory {
        verified_proof_history: vector<vector<u8>>,
        invalid_proof_history: vector<vector<u8>>,
        reported_tower_height: u64,
        verified_tower_height: u64, // user's latest verified_tower_height
        latest_epoch_mining: u64,
        epochs_validating_and_mining: u64,
        contiguous_epochs_validating_and_mining: u64,
    }

    // Struct to store all proofs since the previous epoch
    resource struct ProofsInEpoch {
        proofs: vector<VdfProofBlob>
    }


    // Creates proof blob object from input parameters
    public fun create_proof_blob(challenge: vector<u8>, difficulty: u64,
                                  solution: vector<u8>,
                                  reported_tower_height: u64) : VdfProofBlob {
       let epoch = LibraConfig::get_current_epoch();
       VdfProofBlob { challenge, difficulty, solution, reported_tower_height, epoch }
    }


    // Returns tower height from input miner's state
    public fun get_miner_tower_height(miner_addr: address): u64 acquires MinerProofHistory {
       borrow_global<MinerProofHistory>(miner_addr).verified_tower_height
    }


    // Returns number of epochs for input miner's state
    public fun get_miner_epochs(miner_addr: address): u64 acquires MinerProofHistory {
       borrow_global<MinerProofHistory>(miner_addr).epochs_validating_and_mining
    }


    // // Tests to confirm that VM genesis (language/tools/vm-genesis/src/lib.rs)
    // // can call MinerProofHistory
    // public fun test_genesis(): bool {
    //   true
    // }


    // Helper function for genesis to begin redeem process.
    public fun genesis_helper (miner: &signer, challenge: vector<u8>, solution: vector<u8> )
                                acquires MinerProofHistory, ProofsInEpoch {

      let difficulty = Globals::get_difficulty();
      let vdf_proof_blob = VdfProofBlob {
        challenge,
        difficulty,  
        solution,
        reported_tower_height: 0,
        epoch: 0,
      };
      commit_state(miner, vdf_proof_blob)
    }


    // This function starts the redeem process.
    public fun commit_state(miner: &signer, vdf_proof_blob: VdfProofBlob) acquires MinerProofHistory, ProofsInEpoch {
      // Get address
      let miner_addr = Signer::address_of( miner );

      // Get difficulty constant. Will be different in tests than in production.
      // Globals initializes this accordingly
      let difficulty_constant = Globals::get_difficulty();

      Transaction::assert(&vdf_proof_blob.difficulty == &difficulty_constant, 180206011010);

      // 1. The Onboarding path (miner not yet initialized):
      //    Check if the miner's state is initialized.
      //    Insert a new VdfProofBlob into a temp storage while saving all of miner's
      //      proofs to the miner's own address, including the first proof sent
      //      by someone else.
      //    This may be the first time the miner is redeeming. If so, both
      //      resources are uninitialized. Initialize them
      if (!::exists<MinerProofHistory>(miner_addr)) {
        // Verify the proof before anything else (i.e. user actually did the delay)
        // TODO: A faster way to check for minor errors, since it's an expensive operation.
        let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
        Transaction::assert(valid, 180206021021);

        // TODO: Create account if there is no account
        // This should look something like this. Below code is untested and can be
        //  implemented after POC stage.
          // if (is_onboarding) {
          //   exists_or_create(vdf_proof_blob);
          // } else {
          //   miner_addr = Signer::address_of( miner );
          // }
        // Initialize the miner state for the new miner
        init_miner_state(miner);

        // Verify the blob and update the newly initialized state
        verify_and_update_state(miner_addr,vdf_proof_blob , false );

      } else {
        //  2. Steady state path (miner has already been initialized)

        // Check to ensure the transaction sender is indeed the miner
        Transaction::assert(Transaction::sender() == miner_addr, 180206031010);

        // Verify the blob and update the state.
        verify_and_update_state(miner_addr,vdf_proof_blob, true  );
      }
    }


    // Function to verify a proof blob and update a MinerProofHistory
    fun verify_and_update_state(miner_addr: address, vdf_proof_blob: VdfProofBlob,
                                initialized_miner: bool)
                                acquires MinerProofHistory, ProofsInEpoch {

      // Get a mutable ref to the current state
      let miner_redemption_state = borrow_global_mut<MinerProofHistory>(miner_addr);

      // If miner has already been initialized much perform extra checks to ensure
      // this proof is unique, etc
      if (initialized_miner) {
        (miner_redemption_state, vdf_proof_blob) = check_duplicate_and_verify(
                                              miner_redemption_state, vdf_proof_blob);
      };

      // 3. Add redeem attempt to invalid_proof_history, which will later be removed with successful verification.
      // Should also surface to client since ClientProxy for submit redeem tx is async.
      // Vector::push_back(&mut global_redemption_state.proof_history, *&vdf_proof_blob.solution);
      Vector::push_back(&mut miner_redemption_state.invalid_proof_history, Hash::sha3_256(*&vdf_proof_blob.solution));

      // TODO: Is there a missing 4th step here?

      // 5. Update the miner's state with pending statistics.
      // remove the proof that was placed provisionally in invalid_proofs, since it passed.
      let removed_solution = Vector::pop_back(&mut miner_redemption_state.invalid_proof_history);
      Transaction::assert(&removed_solution == &Hash::sha3_256(*&vdf_proof_blob.solution), 180207011010);

      // 6. Update resources and statistics.
      // Add the correct proof
      Vector::push_back(&mut miner_redemption_state.verified_proof_history, Hash::sha3_256(*&vdf_proof_blob.solution));
      Transaction::assert(Vector::length(&miner_redemption_state.verified_proof_history) > 0, 180207021010);

      // Increment the verified_tower_height
      miner_redemption_state.verified_tower_height = miner_redemption_state.verified_tower_height + 1;
      // NOTE: this is used by end_redeem
      miner_redemption_state.latest_epoch_mining = LibraConfig::get_current_epoch();

      // Prepare list of proofs in epoch for end of epoch statistics
      let in_process = borrow_global_mut<ProofsInEpoch>(miner_addr);
      Vector::push_back(&mut in_process.proofs, copy vdf_proof_blob);
      // Adds the address to the Validator Universe state. TBD if this is forever.
      // This signifies that the miner has done legitimate work, and can now be included in validator set.
      // For every  VDF proof that is correct, add the address and the epoch to the struct.
      ValidatorUniverse::add_validator( miner_addr );
    }


    // Helper function which checks if proof has already been submitted and
    // verifies that proof is valid.
    fun check_duplicate_and_verify(miner_redemption_state: &mut MinerProofHistory,
                                    vdf_proof_blob: VdfProofBlob):
                                    (&mut MinerProofHistory, VdfProofBlob) {
      // Checks that the blob was not previously submitted.
      // If previously redeemed, its a no-op with error.
      let hash_of_solution = Hash::sha3_256(*&vdf_proof_blob.solution);
      let is_previously_submitted_proof = Vector::contains(&miner_redemption_state.verified_proof_history, &hash_of_solution );
      Transaction::assert(is_previously_submitted_proof == false, 180208011020);
      let is_previously_submitted_invalid_proof = Vector::contains(&miner_redemption_state.invalid_proof_history, &hash_of_solution );
      Transaction::assert(is_previously_submitted_invalid_proof == false, 180208021020);

      // Check that the proof presented previously matches the current preimage.
      let proofs_count = Vector::length(&miner_redemption_state.verified_proof_history);
      let last_verified_proof = Vector::borrow(
        &miner_redemption_state.verified_proof_history,
        proofs_count - 1);
      Transaction::assert(last_verified_proof == &Hash::sha3_256(*&vdf_proof_blob.challenge), 180208031010);

      // Verify proof is valid
      let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid, 180208041021);
      (miner_redemption_state, vdf_proof_blob)
    }


    // MinerState::update_metrics() checks that the miner has been doing validation AND that
    // there are mining proofs presented in the last/current epoch.
    // TODO: check that there are mining proofs presented in the current/outgoing epoch (within which the end_redeem is being called)
    public fun update_metrics(miner_addr: address) acquires ProofsInEpoch, MinerProofHistory {
      // The goal of end_redeem is to confirm that a miner participated in consensus during
      // an epoch, but also that there were mining proofs submitted in that epoch.

      // 0. Check for errors and authorization
      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0, 180209014010);

      // Miner may not have been initialized. Simply return in this case (don't abort)
      if( ! ::exists<ProofsInEpoch>( miner_addr ) ){
        return
      };

      // 1. Check that there was mining and validating in period.
      // Account may not have any proofs submitted in epoch, since the resource was last emptied.

      // TODO: MinerProofHistory.move count the number of proofs in epoch, and don't count validation that is not credible.
      // BODY: need to make this check more sophisticated. Placeholder for now.
      let proofs_in_epoch = borrow_global_mut<ProofsInEpoch>(miner_addr);

      // 2. Update statistics.
      let miner_redemption_state= borrow_global_mut<MinerProofHistory>(miner_addr);
      let this_epoch = LibraConfig::get_current_epoch();
      miner_redemption_state.latest_epoch_mining = this_epoch;
      miner_redemption_state.epochs_validating_and_mining = miner_redemption_state.epochs_validating_and_mining + 1;
      miner_redemption_state.contiguous_epochs_validating_and_mining = miner_redemption_state.contiguous_epochs_validating_and_mining + 1;

      // 3. Clear the state of these in_process proofs.
      // Either they were redeemed or they were not relevant for updating the user delay history.
      proofs_in_epoch.proofs = Vector::empty();
    }


    // Get weight of validator identified by address
    public fun get_validator_weight(miner_addr: address): u64 acquires MinerProofHistory {
      // Permission check
      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0, 180210014010);

      // Miner may not have been initialized. (don't abort, just return 0)
      if( ! ::exists<ProofsInEpoch>( miner_addr ) ){
        return 0
      };

      // Update the statistics.
      let miner_redemption_state= borrow_global_mut<MinerProofHistory>(miner_addr);
      let this_epoch = LibraConfig::get_current_epoch();
      miner_redemption_state.latest_epoch_mining = this_epoch;

      // Return it's weight
      miner_redemption_state.epochs_validating_and_mining
    }


    // Bulk update the end_redeem state with the vector of validators from current epoch.
    public fun end_redeem_validator_universe(account: &signer)
                  acquires ProofsInEpoch, MinerProofHistory {
      // Check permissions
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 180211014010);

      // Get list of validators from ValidatorUniverse
      let eligible_validators = ValidatorUniverse::get_eligible_validators(account);

      // Iterate through validators and call redeem for each validator
      // that had proofs this epoch
      let size = Vector::length<address>(&eligible_validators);
      let i = 0;
      while (i < size) {
          let redeemed_addr = *Vector::borrow(&eligible_validators, i);

          // For testing: don't call end_redeem unless there is account state for the address.
          if ( ::exists<ProofsInEpoch>( redeemed_addr ) ){
              update_metrics(redeemed_addr);
          };
          i = i + 1;
      };
    }


    // Helper function to initialize miner state
    fun init_miner_state(miner: &signer){
      // Initialize vector of proofs in current epoch and give to miner account
      move_to<ProofsInEpoch>( miner, ProofsInEpoch{proofs: Vector::empty()});

      // Initialize MinerProofHistory object and give to miner account
      move_to<MinerProofHistory>(miner, MinerProofHistory{
        verified_proof_history: Vector::empty(),
        invalid_proof_history: Vector::empty(),
        reported_tower_height: 0u64,
        verified_tower_height: 0u64, // user's latest verified_tower_height
        latest_epoch_mining: 0u64,
        epochs_validating_and_mining: 0u64,
        contiguous_epochs_validating_and_mining: 0u64,
      });
    }


    // Process and check the first proof blob submitted for validity (includes correct address)
    public fun first_challenge_includes_address(new_account_address: address, challenge: &vector<u8>) {
      // GOAL: To check that the preimage/challenge of the FIRST VDF proof blob contains a given address.
      // This is to ensure that the same proof is not sent repeatedly, since all the minerstate is on a
      // the address of a miner.
      // Note: The bytes of the miner challenge is as follows:
      //         32 // OL Key
      //         +64 // chain_id
      //         +8 // iterations/difficulty
      //         +1024; // statement

      // Calling native function to do this parsing in rust
      // The auth_key must be at least 32 bytes long
      Transaction::assert(Vector::length(challenge) >= 32, 180213011000);
      let (parsed_address, _auth_key) = VDF::extract_address_from_challenge(challenge);
      // Confirm the address is corect and included in challenge
      Transaction::assert(new_account_address == parsed_address, 180213021010);

    }
  }
}
