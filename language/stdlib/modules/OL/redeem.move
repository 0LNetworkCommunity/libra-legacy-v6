// 401- Unauthrized access (only association allowed)
  address 0x0 {

  // Note: This module needs a key-value store.
  module Redeem {
    use 0x0::VDF;
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::Debug;
    use 0x0::ValidatorUniverse;
    use 0x0::Signer;
    use 0x0::LibraConfig;

    struct VdfProofBlob {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
        reported_tower_height: u64,
        epoch: u64,
    }

    resource struct MinerState {
        verified_proof_history: vector<vector<u8>>,
        invalid_proof_history: vector<vector<u8>>,
        reported_tower_height: u64,
        verified_tower_height: u64, // user's latest verified_tower_height
        latest_epoch_mining: u64,
        epochs_validating_and_mining: u64,
        contiguous_epochs_validating_and_mining: u64,
    }

    resource struct ProofsInEpoch { // every proof since the last epoch.
        proofs: vector<VdfProofBlob>
    }

    public fun create_proof_blob(challenge: vector<u8>, difficulty: u64, solution: vector<u8>, reported_tower_height: u64) : VdfProofBlob{
       let epoch = LibraConfig::get_current_epoch();
       VdfProofBlob { challenge, difficulty, solution, reported_tower_height, epoch }
    }

    public fun get_miner_tower_height(miner_addr: address): u64 acquires MinerState {
      // Get tower height from miner's state.
       borrow_global<MinerState>(miner_addr).verified_tower_height
    }

    public fun get_miner_epochs(miner_addr: address): u64 acquires MinerState {
      // Get tower height from miner's state.
       borrow_global<MinerState>(miner_addr).epochs_validating_and_mining
    }

    public fun begin_redeem(miner: &signer, vdf_proof_blob: VdfProofBlob) acquires MinerState, ProofsInEpoch {
      Debug::print(&0x12edee11100000000000000000001000);

      //0. Check for errors
      let miner_addr = Signer::address_of( miner );
      // Check difficulty is correct
      // will be different in tests than in production.
      //// IMPORTANT CONSTANT ////
      // TODO: Difficulty constant needs to switch between test configuration and production.
      let difficulty_constant = 100u64;
      //// IMPORTANT CONSTANT ////

      Transaction::assert(&vdf_proof_blob.difficulty == &difficulty_constant, 100080002);

      // 1. check if the miner's state is initialized
      // Insert a new VdfProofBlob into a temp storage, while
      // Save all of miner's proofs to the its own address, including the first proof sent by someone else.

      // this may be the first time the miner is redeeming. If so, both resources are uninitialized.
      if (!::exists<ProofsInEpoch>(miner_addr)) {
        init_in_process(miner);
      };

      if (!::exists<MinerState>(miner_addr)) {
        // // TODO: Check the First VDF proof CHALLENGE, for the address the miner wants to register.
        // // Then create a validator account with that address (and public key)
        // let new_address = first_challenge_includes_address(challenge);
        //
        // //2. create a new validator account.
        // // TODO: we need the public key as well as the address for this.
        // // public key is 64 byte hex, and address is a 16 byte hex.
        // LibraAccount::create_validator_account<GAS::T>(sender, new_account_address, auth_key_prefix);

        // initialize the miner state.
        init_miner_state(miner);
      };

      // 2. check if this proof has been submitted before.
      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.
      let miner_redemption_state= borrow_global_mut<MinerState>(miner_addr);
      let is_previously_submitted_proof = Vector::contains(&miner_redemption_state.verified_proof_history, &vdf_proof_blob.solution);
      Debug::print(&is_previously_submitted_proof);

      Transaction::assert(is_previously_submitted_proof == false, 100080002);
      let is_previously_submitted_invalid_proof = Vector::contains(&miner_redemption_state.invalid_proof_history, &vdf_proof_blob.solution);
      Debug::print(&is_previously_submitted_invalid_proof);

      Transaction::assert(is_previously_submitted_invalid_proof == false, 100080003);

      // 3. Add redeem attempt to invalid_proof_history, which will later be removed with successful verification.
      // Should also surface to client since ClientProxy for submit redeem tx is async.
      // Vector::push_back(&mut global_redemption_state.proof_history, *&vdf_proof_blob.solution);
      Vector::push_back(&mut miner_redemption_state.invalid_proof_history, *&vdf_proof_blob.solution);

      // 4. Verify the proof.
      // The main point of this Redeem: Checks that the user did run the delay (VDF).
      // Calling Verify() to check the validity of Blob
      let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid == true, 100080004);
      Debug::print(&0x12edee11100000000000000000001001);

      // 5. Update the miner's state with pending statistics.
      // remove the proof that was placed provisionally in invalid_proofs, since it passed.
      // let removed_solution = Vector::pop_back(&mut miner_redemption_state.invalid_proof_history);
      // Transaction::assert(&removed_solution == &vdf_proof_blob.solution, 100080005);

      // 6. Update resources and statistics.
      // let test = copy vdf_proof_blob.solution;
      // add the correct proof
      Vector::push_back(&mut miner_redemption_state.verified_proof_history, *&vdf_proof_blob.solution);
      // Debug::print(&Vector::length(&miner_redemption_state.verified_proof_history));
      Transaction::assert(Vector::length(&miner_redemption_state.verified_proof_history) > 0, 100080011);


      Debug::print(&0x12edee11100000000000000000001002);

      // increment the verified_tower_height
      miner_redemption_state.verified_tower_height = miner_redemption_state.verified_tower_height + 1; // user's latest verified_tower_height
      // NOTE: this is used by end_redeem
      miner_redemption_state.latest_epoch_mining = LibraConfig::get_current_epoch();
      Debug::print(&0x12edee11100000000000000000001003);

      // prepare list of proofs in epoch for end of epoch statistics
      let in_process = borrow_global_mut<ProofsInEpoch>(miner_addr);
      Vector::push_back(&mut in_process.proofs, copy vdf_proof_blob);
      // Adds the address to the Validator Universe state. TBD if this is forever.
      // This signifies that the miner has done legitimate work, and can now be included in validator set.
      // For every  VDF proof that is correct, add the address and the epoch to the struct.

      ValidatorUniverse::add_validator( miner_addr );
      Debug::print(&0x12edee11100000000000000000001004);

    }

    // Redeem::end_redeem() checks that the miner has been doing
    // validation AND that there are mining proofs presented in the last/current epoch.
    // TODO: check that there are mining proofs presented in the current/outgoing epoch (within which the end_redeem is being called)
    public fun end_redeem(miner_addr: address) acquires ProofsInEpoch, MinerState {
      Debug::print(&0x12edee11100000000000000000002000);

      // The goal of end_redeem is to confirm that a miner participated in consensus during
      // an epoch, but also that there were mining proofs submitted in that epoch.
      //0. Check for errors and authorization
      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0 || sender == 0xA550C18, 100080006);

      // may not have been initialized
      if( ! ::exists<ProofsInEpoch>( miner_addr ) ){
        return // should not abort.
      };
      Debug::print(&0x12edee11100000000000000000002001);

      //1. Check that there was mining and validating in period.
      // Account may not have any proofs submitted in epoch, since the resource was last emptied.

      // TODO: Redeem.move count the number of proofs in epoch, and don't count validation that is not credible.
      // BODY: need to make this check more sophisticated. Placeholder for now.
      let proofs_in_epoch = borrow_global_mut<ProofsInEpoch>(miner_addr);
      let counts = Vector::length(&proofs_in_epoch.proofs);
      Transaction::assert(counts > 0, 100080007);
      Debug::print(&0x12edee11100000000000000000002002);

      //2. Update the statistics.
      let miner_redemption_state= borrow_global_mut<MinerState>(miner_addr);
      let previous_epoch_which_mined = miner_redemption_state.latest_epoch_mining;
      let this_epoch = LibraConfig::get_current_epoch();
      miner_redemption_state.latest_epoch_mining = this_epoch;
      miner_redemption_state.epochs_validating_and_mining = miner_redemption_state.epochs_validating_and_mining + 1;

      // NOTE: this is duplicate data because calling Redeem from Validator universe causes a dependency cycling error.
      ValidatorUniverse::update_validator_epoch_count(miner_addr);

      Debug::print(&0x12edee11100000000000000000002003);

      if (previous_epoch_which_mined - this_epoch <= 1) {
        // increment if contiguous epochs
        miner_redemption_state.contiguous_epochs_validating_and_mining = miner_redemption_state.contiguous_epochs_validating_and_mining + 1;
      } else {
        // reset
        miner_redemption_state.contiguous_epochs_validating_and_mining = miner_redemption_state.contiguous_epochs_validating_and_mining + 1;
      };

      Debug::print(&0x12edee11100000000000000000002004);

      // 3. Clear the state of these in_process proofs.
      // Either they were redeemed or they were not relevant for updating the user delay history.
      proofs_in_epoch.proofs = Vector::empty();
    }

    // Bulk update the end_redeem state with the vector of validators from current epoch.
    public fun end_redeem_outgoing_validators(account: &signer, outgoing_validators: &vector<address>)
    acquires ProofsInEpoch, MinerState {
      Debug::print(&0x12edee11100000000000000000003000);

      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0 || sender == 0xA550C18, 100080008);

      let size = Vector::length(outgoing_validators);

      let i = 0;
      while (i < size) {
          let redeemed_addr = *Vector::borrow(outgoing_validators, i);
          Debug::print(&0x12EDEE11100000000000000000001004);

          Debug::print(&redeemed_addr);

          // For testing: don't call end_redeem unless there is account state for the address.
          if ( ::exists<ProofsInEpoch>( redeemed_addr ) ){
              end_redeem(redeemed_addr);
              Debug::print(&0x12EDEE11100000000000000000001005);
          };
          i = i + 1;
      };
    }

    // public fun make_account_from_keys () {
    //
    //   fun make_account<Token, RoleData: copyable>(
    //       new_account: signer,
    //       auth_key_prefix: vector<u8>,
    //       role_data: RoleData,
    //       add_all_currencies: bool
    //     );
    // };


    // Initialize the module and state. This can only be invoked by the default system address to instantiate
    // the resource under that address.
    // It can only be called a single time in the genesis transaction.
    // public fun initialize(_config_account: &signer) {
    //     //Transaction::assert( Signer::address_of(account) == default_redeem_address(), 10003);
    //     // move_to<T>( config_account, T{ verified_tower_height: 0 });
    //     // move_to<MinerState>( config_account, MinerState{ proof_history: Vector::empty() });
    //
    //     // move_to<MinerState>( miner, MinerState{ proof_history: Vector::empty(), proofs: Vector::empty(), verified_tower_height: 0u64});
    //
    // }

    // fun default_redeem_address(): address {
    //     0xA550C18
    // }

    fun init_in_process(miner: &signer){
        move_to<ProofsInEpoch>( miner, ProofsInEpoch{proofs: Vector::empty()});
    }

    fun init_miner_state(miner: &signer){

      move_to<MinerState>(miner, MinerState{
        verified_proof_history: Vector::empty(),
        invalid_proof_history: Vector::empty(),
        reported_tower_height: 0u64,
        verified_tower_height: 0u64, // user's latest verified_tower_height
        latest_epoch_mining: 0u64,
        epochs_validating_and_mining: 0u64,
        contiguous_epochs_validating_and_mining: 0u64,
      });
    }

    public fun first_challenge_includes_address(new_account_address: address, challenge: vector<u8>) {
      // GOAL: To check that the preimage/challenge of the FIRST VDF proof blob contains a given address.
      // This is to ensure that the same proof is not sent repeatedly, since all the minerstate is on a
      // the address of a miner.
      // Note: The bytes of the miner challenge is as follows:
      //         32 // OL Key
      //         +64 // chain_id
      //         +8 // iterations/difficulty
      //         +1024; // statement

      let slice_challenge_to_address = Vector::empty<u8>();

      let i = 0;
      while (i < 16) {
        let test = *Vector::borrow(&challenge, i);
        Vector::push_back(&mut new_hex, *&test);
        Debug::print(&test);

        i = i + 1;
      };

      Transaction::assert(new_account_address == slice_challenge_to_address, 100080002);

      Debug::print(&new_hex);
      Debug::print(&new_account_address);
    }

    // fun has(addr: address): bool {
    //    ::exists<T>(addr)
    // }
  }
  }
