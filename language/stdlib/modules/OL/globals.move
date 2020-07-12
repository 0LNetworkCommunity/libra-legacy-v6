address 0x0 {

module Globals {
    // use 0x0::Event;
    // use 0x0::LibraSystem;
    // use 0x0::LibraTimestamp;
    use 0x0::Signer;
    use 0x0::Transaction;
    use 0x0::Vector;
    // use 0x0::Stats;
    // use 0x0::ReconfigureOL;
    use 0x0::Testnet;

    // resource struct BlockConstantsGlobal {
    //   epoch_length: u64,
    //   max_validator_per_epoch: u64
    // }
    struct GlobalConstants {
      epoch_length: u64,
      max_validator_per_epoch: u64
    }

    resource struct BlockMetadataGlobal {
      // TODO: This is duplicated with LibraBlockGlobal, but that one causes a cyclic dependency issue because of stats.
      height: u64,
      round: u64,
      previous_block_votes: vector<address>,
      proposer: address,
      time_microseconds: u64,
    }
    // This can only be invoked by the Association address, and only a single time.
    // Currently, it is invoked in the genesis transaction
    public fun initialize_block_metadata(account: &signer) {
      // Only callable by the Association address
      Transaction::assert(Signer::address_of(account) == 0x0, 1);

      move_to<BlockMetadataGlobal>(
          account,
          BlockMetadataGlobal {
            height: 0,
            round: 0,
            previous_block_votes: Vector::singleton(0x0),
            proposer: 0x0,
            time_microseconds: 0,
          }
      );
    }


    ////////////////////
    //// Metadata ////
    ///////////////////
    // Get the current block height
    public fun get_current_block_height(): u64 acquires BlockMetadataGlobal {
      borrow_global<BlockMetadataGlobal>(0x0).height
    }

    // Get the previous block voters
    public fun get_previous_voters(): vector<address> acquires BlockMetadataGlobal {
       let voters = *&borrow_global<BlockMetadataGlobal>(0x0).previous_block_votes;
       return voters //vector<address>
    }

    ////////////////////
    //// Constants ////
    ///////////////////

    // Get the epoch length
    public fun get_epoch_length(): u64 {
       get_constants().epoch_length
    }

    // Get max validator per epoch
    public fun get_max_validator_per_epoch(): u64 {
       get_constants().max_validator_per_epoch
    }

    public fun get_constants(): GlobalConstants  {
      if (Testnet::is_testnet()){
        return GlobalConstants {
          epoch_length: 15,
          max_validator_per_epoch: 10
        }

      } else {
        return GlobalConstants {
          epoch_length: 2000000,
          max_validator_per_epoch: 300
        }
      }
    }

    // Get the current block height
    public fun update_global_metadata(vm: &signer) acquires BlockMetadataGlobal {
      Transaction::assert(Signer::address_of(vm) == 0x0, 33);
      let data = borrow_global_mut<BlockMetadataGlobal>(0x0);
      data.height = 999
    }
}

}
