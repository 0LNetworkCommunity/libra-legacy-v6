address 0x0 {
  module Redeem {
    // Note: This module needs a key-value store.

    // pub fun begin_redeem(pubkey, vdf_proof_blob) {
      // Permissions: anyone can call this contract.

      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.

      // Checks that the user did run the delay (VDF). Calling Verify() to check the validity of Blob

      //  Verify()

      // If successfully verified, store the pubkey, proof_blob, mint_transaction to the Redeem k-v marked as a "redemtion in process"
      // [Storage]
    //}

    // pub fun end_redeem(pubkey, vdf_proof_blob) {
      // Permissions: Only the 0x0 address can call this, when an epoch ends.

      // Calls Stats module to check that pubkey was engaged in consensus, that the n% liveness above.
      // Stats(pubkey, block)

      // Also counts that the minimum amount of VDFs were completed during a time (cannot submit proofs that were done concurrently with same information on different CPUs).
      // TBD

      // If those checks are successful Redeem calls Subsidy module (which subsequently calls the  Gas_Coin.Mint function).
      // Subsidy(pubkey, quantity)
    //}
  }
}
