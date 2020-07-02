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
        tower_height: u64,
        epoch: u64,
    }

    // resource struct T {
    //     tower_height: u64, // current tower_height of the network
    // }

    // Saves all submitted proofs as a global variable.
    // This is going to be a very large blob. consider to save proof's hash to reduce disk spaces.
    resource struct MinerState {
        history: vector<vector<u8>>,
        proofs: vector<VdfProofBlob>,
        tower_height: u64, // user's latest tower_height
        // longest_epoch_streak: u64,
    }

    resource struct MinerStateDup {
        history: vector<vector<u8>>,
        proofs: vector<VdfProofBlob>,
        tower_height: u64, // user's latest tower_height
        // longest_epoch_streak: u64,
    }

    resource struct InProcess {
        tower_height: u64, // user's latest tower_height
        proofs: vector<VdfProofBlob>
    }

    public fun create_proof_blob(challenge: vector<u8>, difficulty: u64, solution: vector<u8>, tower_height: u64) : VdfProofBlob{
       let epoch = LibraConfig::get_current_epoch();
       VdfProofBlob {challenge, difficulty, solution, tower_height, epoch }
    }

    // public fun get_current_tower_height(): u64 acquires T {
    //    borrow_global_mut<T>(default_redeem_address()).tower_height
    // }

    public fun get_miner_tower_height(miner_addr: address): u64 acquires InProcess {
      // NOTE: Should get tower height from global.
       borrow_global_mut<InProcess>(miner_addr).tower_height
    }

    // public fun increment_tower_height() acquires T {
    //    let t = borrow_global_mut<T>(default_redeem_address());
    //    t.tower_height = t.tower_height + 1;
    // }

    public fun begin_redeem(miner: &signer, vdf_proof_blob: VdfProofBlob) acquires MinerState, MinerStateDup, InProcess {

      let miner_addr = Signer::address_of( miner );

      // Insert a new VdfProofBlob into a temp storage, while
      // Save all of miner's proofs to the its own address, including the first proof sent by someone else.
      if (!has_in_process(miner)) {
        // this may be the first time the miner is redeeming.
        // check if it is the genesis tower proof.
        // the challenge should be easily parsed by the bitlength.
        // TODO: check the first challenge.

        // TODO: initialize miner state in miner account.
        init_in_process(miner);
      };

      if (!has_miner_state(miner)) {
        Debug::print(&0x00000012123123123);

        init_miner_state(miner);
      };


      // Checks that the blob was not previously redeemed, if previously redeemed its a no-op, with error message.
      let global_redemption_state = borrow_global_mut<MinerState>(default_redeem_address());
      let miner_redemption_state= borrow_global_mut<MinerStateDup>(miner_addr);


      let blob_redeemed = Vector::contains(&global_redemption_state.history, &vdf_proof_blob.solution);
      let blob_redeemed_miner = Vector::contains(&miner_redemption_state.history, &vdf_proof_blob.solution);


      Transaction::assert(blob_redeemed == false, 0100080001);
      Transaction::assert(blob_redeemed_miner == false, 0100080001);

      // TODO: need an erorr message that gets surfaced to Node logs
      // if blob_redeemed == true {
      //    Debug::print(0100080005);
      // }
      // Should also surface to client since ClientProxy for submit redeem tx is async.
      Vector::push_back(&mut global_redemption_state.history, *&vdf_proof_blob.solution);
      Vector::push_back(&mut miner_redemption_state.history, *&vdf_proof_blob.solution);

      // The main point of this Redeem: Checks that the user did run the delay (VDF).
      // Calling Verify() to check the validity of Blob
      let valid = VDF::verify(&vdf_proof_blob.challenge, &vdf_proof_blob.difficulty, &vdf_proof_blob.solution);
      Transaction::assert(valid == true, 0100080002);


      // Adds the address to the Validator Universe state. TBD if this is forever.
      // This signifies that the miner has done legitimate work, and can now be included in validator set.
      // For every  VDF proof that is correct, add the address and the epoch to the struct.
      ValidatorUniverse::add_validator( miner_addr );

      // Update InProcess
      // If successfully verified, store a proof blob in a transitional resource InProcess
      let in_process = borrow_global_mut<InProcess>(miner_addr);
      if(in_process.tower_height < vdf_proof_blob.tower_height) {
            in_process.tower_height = vdf_proof_blob.tower_height;  //update miner's on-chain tower_height
      };

      Vector::push_back(&mut in_process.proofs, copy vdf_proof_blob);
      // Update MinerState
      Vector::push_back(&mut miner_redemption_state.proofs, vdf_proof_blob);
    }

    // Redeem::end_redeem() checks that the miner has been doing
    // validation AND that there are mining proofs presented in the last/current epoch.
    // TODO: check that there are mining proofs presented in the current/outgoing epoch (within which the end_redeem is being called)
    public fun end_redeem(redeemed_addr: address) acquires InProcess {
      // The goal of end_redeem is to confirm that a miner participated in consensus during
      // an epoch, but also that there were mining proofs submitted in that epoch.

      let sender = Transaction::sender();
      Transaction::assert(sender == 0x0 || sender == 0xA550C18, 0100080003);

      if( ! ::exists<InProcess>( redeemed_addr ) ){
        return // should not abort.
      };

      // Account may not have any proofs submitted recently.
      let in_process_redemption = borrow_global_mut<InProcess>(redeemed_addr);
      let counts = Vector::length(&in_process_redemption.proofs);
      Transaction::assert(counts > 0, 0100080004);

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
    acquires InProcess {
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
        // move_to<T>( config_account, T{ tower_height: 0 });
        move_to<MinerState>( config_account, MinerState{ history: Vector::empty(),
                            proofs: Vector::empty(),
                            tower_height: 0u64 });

        // move_to<MinerStateDup>( miner, MinerStateDup{ history: Vector::empty(), proofs: Vector::empty(), tower_height: 0u64});

    }

    fun default_redeem_address(): address {
        0xA550C18
    }

    fun has_in_process(miner: &signer): bool {
       ::exists<InProcess>(Signer::address_of(miner))
    }

    fun has_miner_state(miner: &signer): bool {
       ::exists<MinerStateDup>(Signer::address_of(miner))
    }

    fun init_in_process(miner: &signer){
        move_to<InProcess>( miner, InProcess{ tower_height: 0u64, proofs: Vector::empty()});
    }

    fun init_miner_state(miner: &signer){
        move_to<MinerStateDup>( miner, MinerStateDup{ history: Vector::empty(), proofs: Vector::empty(), tower_height: 0u64});
    }

    // fun has(addr: address): bool {
    //    ::exists<T>(addr)
    // }
  }
}
