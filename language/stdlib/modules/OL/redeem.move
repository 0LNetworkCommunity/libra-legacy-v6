address 0x0 {

  // Note: This module needs a key-value store.
  module Redeem {
    use 0x0::VDF;
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::Debug;
    use 0x0::LibraConfig;
    //use 0x0::Signer;

    struct VdfProofBlob {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
        height: u64,
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

    public fun begin_redeem(vdf_proof_blob: VdfProofBlob) acquires T, InProcess{
      // Initialize
      if (!has_in_process()) {
           init_in_process();
      };

      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.
      let global_redemption_state = borrow_global_mut<T>(default_redeem_address());
      let blob_redeemed = Vector::contains(&global_redemption_state.history, &vdf_proof_blob.solution);
      Transaction::assert(blob_redeemed == false, 0100080001);
      // TODO: need an erorr message that gets surfaced to Node logss.
      // Should also surface to client since ClientProxy for submit redeem tx is async.

      // QUESTION: Should we save a UserProof that is false so that we know it's been attempted multiple times?
      Vector::push_back(&mut global_redemption_state.history, *&vdf_proof_blob.solution);

      // Checks that the user did run the delay (VDF). Calling Verify() to check the validity of Blob
      let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid == true, 0100080002);

      // If successfully verified, store the pubkey, proof_blob, mint_transaction to the Redeem k-v marked as a "redemption in process"
      let in_process = borrow_global_mut<InProcess>(Transaction::sender());
      vdf_proof_blob.height = global_redemption_state.tower_height;
      Vector::push_back(&mut in_process.proofs, vdf_proof_blob);

    }

    public fun end_redeem(redeemed_addr: address) acquires InProcess,T {
      // Permissions: Only a specified address (0x0 address i.e. default_redeem_address) can call this, when an epoch ends.
      let sender = Transaction::sender();
      Transaction::assert(sender == default_redeem_address(), 0100080003);

      // Account do not have proof to verify.
      let in_process_redemption = borrow_global_mut<InProcess>(redeemed_addr);
      let counts = Vector::length(&in_process_redemption.proofs);
      Transaction::assert(counts > 0, 0100080004);

      let global_redemption_state = borrow_global_mut<T>(default_redeem_address());
      global_redemption_state.tower_height = global_redemption_state.tower_height + 1;

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
        //Transaction::assert( Signer::address_of(account) == default_redeem_address(), 10003);
        move_to<T>( config_account ,T{ history: Vector::empty(), tower_height: 0 });
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
