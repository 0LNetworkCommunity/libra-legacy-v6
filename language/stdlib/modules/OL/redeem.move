// 401- Unauthrized access (only association allowed)
address 0x0 {

  // Note: This module needs a key-value store.
  module Redeem {
    use 0x0::VDF;
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::Debug;
    use 0x0::LibraConfig;
    use 0x0::Signer;

    struct VdfProofBlob {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
    }

    resource struct T {
        history: vector<vector<u8>>,
    }

    resource struct InProcess {
        proofs: vector<VdfProofBlob>,
    }

     ///////////////////////////////////////////////////////////////////////////
    // Validator Universe
    ///////////////////////////////////////////////////////////////////////////

    // resource for tracking the universe of accounts that have submitted a proof correctly, with the epoch number. 
    resource struct ValidatorUniverse {
      addresses: vector<address>, 
      epoch: u64, // The epoch that the proof was submitted in, for ease in querying.
    }

    // This function is called to add validator to the validator universe.
    fun add_validator(addr: address) acquires ValidatorUniverse {

        let collection = borrow_global_mut<ValidatorUniverse>(0xA550C18);

        if(!Vector::contains<address>(&mut collection.addresses, &addr))
          Vector::push_back<address>(&mut collection.addresses, addr);
    }


     ///////////////////////////////////////////////////////////////////////////
    // Public functions 
    ///////////////////////////////////////////////////////////////////////////

    // function to initialize ValidatorUniverse in genesis.
    // This is triggered in new epoch by Configuration in Genesis.move
    public fun initialize_validator_universe(account: &signer){
      move_to<ValidatorUniverse>(account, ValidatorUniverse {
            addresses: Vector::empty<address>(),
            epoch: 0,
        }
      );
    }
    
    // function to re-initialize ValidatorUniverse in new epoch.
    // This is triggered in new epoch by Configuration in block prologue
    public fun new_epoch_validator_universe_update(account: &signer) acquires ValidatorUniverse {

        Transaction::assert(Signer::address_of(account) == 0x0 || Signer::address_of(account) == 0xA550C18, 401);

        let collection = borrow_global_mut<ValidatorUniverse>(0xA550C18);
        collection.epoch = collection.epoch + 1;
        collection.addresses = Vector::empty();
    }
    
    // A simple public function to query the EligibleValidators.
    // Only association should be able to access this function
    public fun query_eligible_validators(account: &signer) : vector<address> acquires ValidatorUniverse {
        
        Transaction::assert(Signer::address_of(account) == 0x0 || Signer::address_of(account) == 0xA550C18, 401);

        let collection = borrow_global<ValidatorUniverse>(0xA550C18);
        
        return *&(collection.addresses)
    }


    public fun create_proof_blob(challenge: vector<u8>, difficulty: u64, solution: vector<u8>,) : VdfProofBlob {
       VdfProofBlob {challenge,  difficulty, solution }
    }

    public fun begin_redeem(vdf_proof_blob: VdfProofBlob) acquires T, InProcess, ValidatorUniverse{
      // Initialize
      if (!has_in_process()) {
           init_in_process();
      };

      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.
      let user_redemption_state = borrow_global_mut<T>(default_redeem_address());
      let blob_redeemed = Vector::contains(&user_redemption_state.history, &vdf_proof_blob.solution);
      Transaction::assert(blob_redeemed == false, 10000);

      // QUESTION: Should we save a UserProof that is false so that we know it's been attempted multiple times?
      Vector::push_back(&mut user_redemption_state.history, *&vdf_proof_blob.solution);

      // Checks that the user did run the delay (VDF). Calling Verify() to check the validity of Blob
      let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid == true, 10001);

      // Adds the address to the Validator Universe state.
      // For every  VDF proof that is correct, add the address and the epoch to the struct.
      add_validator(Transaction::sender());

      // If successfully verified, store the pubkey, proof_blob, mint_transaction to the Redeem k-v marked as a "redemption in process"
      let in_process = borrow_global_mut<InProcess>(Transaction::sender());
      Vector::push_back(&mut in_process.proofs, vdf_proof_blob);

    }

    public fun end_redeem(redeemed_addr: address) acquires InProcess {
      // Permissions: Only a specified address (0x0 address i.e. default_redeem_address) can call this, when an epoch ends.
      let sender = Transaction::sender();
      Transaction::assert(sender == default_redeem_address(), 10003);

      // Account do not have proof to verify.
      let in_process_redemption = borrow_global_mut<InProcess>(redeemed_addr);
      let counts = Vector::length(&in_process_redemption.proofs);
      Transaction::assert(counts > 0, 10002);

      // Calls Stats module to check that pubkey was engaged in consensus, that the n% liveness above.
      // Stats(pubkey, block)

      // Also counts that the minimum amount of VDFs were completed during a time (cannot submit proofs that were done concurrently with same information on different CPUs).
      // TBD
      Debug::print(&counts);

      // If those checks are successful Redeem calls Subsidy module (which subsequently calls the  Gas_Coin.Mint function).
      // Subsidy(pubkey, quantity)

      // Clean In Process
      in_process_redemption.proofs = Vector::empty();
    }

    // This can only be invoked by the default redeem address to instantiate
    // the resource under that address.
    // It can only be called a single time. it should be invoked in the genesis transaction.
    public fun initialize(config_account: &signer) {
        Transaction::assert( Transaction::sender() == default_redeem_address(), 10003);
        move_to<T>( config_account ,T{ history: Vector::empty()});
    }

    fun default_redeem_address(): address {
        LibraConfig::default_config_address()
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
