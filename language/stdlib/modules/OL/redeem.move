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

    struct VdfProofBlob {
        // TODO: This should include the netork epoch number. Also change "height" name to disambiguate.
        // This should be called tower_height.
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
        height: u64, // tower_height?
    }

    resource struct T {
        history: vector<vector<u8>>,
        tower_height: u64,
    }

    resource struct InProcess {
        proofs: vector<VdfProofBlob>,
    }

    public fun create_proof_blob(challenge: vector<u8>, difficulty: u64, solution: vector<u8>) : VdfProofBlob {
       VdfProofBlob {challenge,  difficulty, solution, height: 0 }
    }

    public fun begin_redeem(vdf_proof_blob: VdfProofBlob) acquires T, InProcess {

      // Insert a new VdfProofBlob into a temp storage, while
      if (!has_in_process()) {
           init_in_process();
      };

      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.
      let global_redemption_state = borrow_global_mut<T>(default_redeem_address());
      let blob_redeemed = Vector::contains(&global_redemption_state.history, &vdf_proof_blob.solution);
      Transaction::assert(blob_redeemed == false, 0100080001);
      // TODO: need an erorr message that gets surfaced to Node logs
      // if blob_redeemed == true {
      //    Debug::print(0100080005);
      // }
      // Should also surface to client since ClientProxy for submit redeem tx is async.
      Vector::push_back(&mut global_redemption_state.history, *&vdf_proof_blob.solution);

      // The main point of this Redeem: Checks that the user did run the delay (VDF).
      // Calling Verify() to check the validity of Blob
      let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid == true, 0100080002);

      // Adds the address to the Validator Universe state. TBD if this is forever.
      // This signifies that the miner has done legitimate work, and can now be included in validator set.
      // For every  VDF proof that is correct, add the address and the epoch to the struct.
      ValidatorUniverse::add_validator(Transaction::sender());

      // If successfully verified, store the pubkey, proof_blob, mint_transaction to the Redeem k-v marked as a "redemption in process"
      let in_process = borrow_global_mut<InProcess>(Transaction::sender());
      vdf_proof_blob.height = global_redemption_state.tower_height;
      Vector::push_back(&mut in_process.proofs, vdf_proof_blob);
    }

    // Redeem::end_redeem() checks that the miner has been doing
    // validation AND that there are mining proofs presented in the last/current epoch.
    // TODO: check that there are mining proofs presented in the current/outgoing epoch (within which the end_redeem is being called)
    public fun end_redeem(redeemed_addr: address) acquires InProcess,T {
      // Permissions: Only system addresses (0x0 address i.e. default_redeem_address) can call this, in an Epoch Prologue i.e. reconfigure event.
      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0 || sender == 0xA550C18, 0100080003);

      if( ! ::exists<InProcess>( redeemed_addr ) ){
        return // should not abort.
    };

      // Account may not have any proofs submitted recently.

      let in_process_redemption = borrow_global_mut<InProcess>(redeemed_addr);
      let counts = Vector::length(&in_process_redemption.proofs);
      Transaction::assert(counts > 0, 0100080004);

      // Note: why is this called "global", looks like it is storing in a user account.
      let global_redemption_state = borrow_global_mut<T>(default_redeem_address());
      global_redemption_state.tower_height = global_redemption_state.tower_height + 1;

      // TODO: Calls Stats module to check that pubkey was engaged in consensus, that the n% liveness above.
      // Stats(pubkey, block)

      // TODO: add a check for proof existing in current Epoch. Also counts that the minimum amount of VDFs were completed during a time (cannot submit proofs that were done concurrently with same information on different CPUs).
      // TBD
      Debug::print(&counts);

      // Clear the state of these in_process proofs.
      // Either they were redeemed or they were not relevant for updating the user delay history.
      in_process_redemption.proofs = Vector::empty();
    }

    // Bulk update the end_redeem state with the vector of validators from current epoch.
    public fun end_redeem_outgoing_validators(account: &signer, outgoing_validators: &vector<address>)
    acquires InProcess, T {
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0 || sender == 0xA550C18, 8001);

      let size = Vector::length(outgoing_validators);

      let i = 0;
      while (i < size) {
          end_redeem(*Vector::borrow(outgoing_validators, i));
          i = i + 1;
      };
    }

    // Initialize the module and state. This can only be invoked by the default system address to instantiate
    // the resource under that address.
    // It can only be called a single time in the genesis transaction.
    public fun initialize(config_account: &signer) {
        //Transaction::assert( Signer::address_of(account) == default_redeem_address(), 10003);
        move_to<T>( config_account ,T{ history: Vector::empty(), tower_height: 0 });
    }

    fun default_redeem_address(): address {
        0xA550C18
    }

    fun has_in_process(): bool {
       ::exists<InProcess>(Transaction::sender())
    }

    fun init_in_process(){
        move_to_sender<InProcess>(InProcess{ proofs: Vector::empty()})
    }

    fun has(addr: address): bool {
       ::exists<T>(addr)
    }
  }
}
