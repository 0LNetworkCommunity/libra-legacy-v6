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
      // Permissions: anyone can call this contract.
      // There is an edgecase which may not be clear. For example: Ping wants to join the network, he did a VDF.
      // He has no gas to submit, he asks to Lucas to submit the VDF (which Ping ran on his computer).

      let user_proof = UserProof{
          pubkey: pubkey,
          proof: vdf_proof_blob,
      };

      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.

      // TODO: This should not be the sender of the transaction.
      // In the example above. Lucas sent a valid proof for Ping.
      // Looks like the implementation below would allow Ping to ask Keerthi to send the transaction again, and he gets two coins.

      let user_redemption_state = borrow_global_mut<T>(Transaction::sender());
      let blob_redeemed = user_redemption_state.history.contains(vdf_proof_blob.solution);
      Transaction::assert(blob_redeemed == true, 10000);

      // Checks that the user did run the delay (VDF). Calling Verify() to check the validity of Blob
      let valid = VDF::verify(vdf_proof_blob.challenge, vdf_proof_blob.difficulty, vdf_proof_blob.solution);
      Transaction::assert(valid == false, 10001);
      // QUESTION: Should we save a UserProof that is false so that we know it's been attempted multiple times?

      // If successfully verified, store the pubkey, proof_blob, mint_transaction to the Redeem k-v marked as a "redemption in process"
      // [Storage]
      Vector::push_back(&mut user_redemption_state.history, vdf_proof_blob.solution);
      let in_process = borrow_global_mut<InProcess>(Transaction::sender());
      Vector::push_back(&mut in_process.proofs, user_proof);

    }

    pub fun end_redeem(pubkey: vector<u8>, vdf_proof_blob: VdfProofBlob) {
      // Permissions: Only a specified address (0x0 address i.e. default_redeem_address) can call this, when an epoch ends.
      let sender = Transaction::sender();
      Transaction::assert(sender != default_redeem_address(), 10003);

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
