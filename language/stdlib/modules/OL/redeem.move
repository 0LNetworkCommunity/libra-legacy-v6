address 0x0 {

  // Note: This module needs a key-value store.
  module Redeem {
    use 0x0::VDF;
    use 0x0::Vector;

    struct VdfProofBlob {
        challenge: vector<u8>,
        difficulty: u64,
        solution: vector<u8>,
    }

    struct UserProof{
        pubkey: vector<u8>,
        proof: VdfProofBlob,
    }

    resource struct T {
        history: vector<u8>,
    }

    resource struct InProcess {
        proofs: vector<UserProof>,
    }

    pub fun begin_redeem(pubkey: vector<u8>, vdf_proof_blob: VdfProofBlob) {

      let user_proof = UserProof{
          pubkey: pubkey,
          proof: vdf_proof_blob,
      };

      // Permissions: anyone can call this contract.
      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.
      let redeems = borrow_global_mut<T>(default_redeem_address());
      let redeemed = redeems.history.contains(vdf_proof_blob.solution);
      Transaction::assert(redeemed == true, 10000);

      // Checks that the user did run the delay (VDF). Calling Verify() to check the validity of Blob
      let valid = VDF::verify(vdf_proof_blob.challenge, vdf_proof_blob.difficulty, vdf_proof_blob.solution);
      Transaction::assert(valid == false, 10001);

      // If successfully verified, store the pubkey, proof_blob, mint_transaction to the Redeem k-v marked as a "redemtion in process"
      // [Storage]
      Vector::push_back(&mut redeems.history, vdf_proof_blob.solution);
      let in_process = borrow_global_mut<InProcess>(default_redeem_address());
      Vector::push_back(&mut in_process.proofs, user_proof);

    }

    pub fun end_redeem(pubkey: vector<u8>, vdf_proof_blob: VdfProofBlob) {
      // Permissions: Only the 0x0 address can call this, when an epoch ends.
      let sender = Transaction::sender();
      Transaction::assert(sender == default_redeem_address(), 1);

      let in_process = borrow_global_mut<InProcess>(default_redeem_address());

      // Calls Stats module to check that pubkey was engaged in consensus, that the n% liveness above.
      // Stats(pubkey, block)

      // Also counts that the minimum amount of VDFs were completed during a time (cannot submit proofs that were done concurrently with same information on different CPUs).
      // TBD

      // If those checks are successful Redeem calls Subsidy module (which subsequently calls the  Gas_Coin.Mint function).
      // Subsidy(pubkey, quantity)

      // clean in process
      Vector::push_back(&mut in_process.proofs, user_proof);
    }

    fun default_redeem_address(): address {
        0x0
    }
  }
}
