///////////////////////////////////////////////////////////////////
// 0L Module
// Globals
///////////////////////////////////////////////////////////////////

address 0x1 {

// TODO: This module is not complete, as Metadata has not been implemented.

module Globals {
    use 0x1::Vector;
    use 0x1::Testnet;
    use 0x1::StagingNet;

    // Some constants need to changed based on environment; dev, testing, prod.
    struct GlobalConstants {
      // For validator set.
      epoch_length: u64,
      max_validator_per_epoch: u64,
      subsidy_ceiling_gas: u64,
      min_node_density: u64,
      max_node_density: u64,
      burn_accounts: vector<address>,
      difficulty: u64,
      epoch_mining_threshold: u64,
    }

    // // Some global state needs to be accesible to every module. Using Librablock causes
    // // cyclic dependency issues.
    // resource struct BlockMetadataGlobal {
    //   // TODO: This is duplicated with LibraBlockGlobal, but that one causes a cyclic dependency issue because of stats.
    //   height: u64,
    //   round: u64,
    //   previous_block_votes: vector<address>,
    //   proposer: address,
    //   time_microseconds: u64,
    // }
    // // This can only be invoked by the Association address, and only a single time.
    // // Currently, it is invoked in the genesis transaction
    // public fun initialize_block_metadata(account: &signer) {
    //   // Only callable by the Association address
    //   Transaction::assert(Signer::address_of(account) == 0x0, 1);

    //   move_to<BlockMetadataGlobal>(
    //       account,
    //       BlockMetadataGlobal {
    //         height: 0,
    //         round: 0,
    //         previous_block_votes: Vector::singleton(0x0),
    //         proposer: 0x0,
    //         time_microseconds: 0,
    //       }
    //   );
    // }


    // ////////////////////
    // //// Metadata /////
    // ///////////////////
    // // Get the current block height
    // public fun get_current_block_height(): u64 acquires BlockMetadataGlobal {
    //   borrow_global<BlockMetadataGlobal>(0x0).height
    // }

    // // Get the previous block voters
    // public fun get_previous_voters(): vector<address> acquires BlockMetadataGlobal {
    //    let voters = *&borrow_global<BlockMetadataGlobal>(0x0).previous_block_votes;
    //    return voters //vector<address>
    // }

    // Get the current block height
    // public fun update_global_metadata(vm: &signer) acquires BlockMetadataGlobal {
    //   Transaction::assert(Signer::address_of(vm) == 0x0, 33);
    //   let data = borrow_global_mut<BlockMetadataGlobal>(0x0);
    //   data.height = 999
    // }

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

    // Get max validator per epoch
    public fun get_subsidy_ceiling_gas(): u64 {
       get_constants().subsidy_ceiling_gas
    }

    // Get max validator per epoch
    public fun get_max_node_density(): u64 {
       get_constants().max_node_density
    }

    // Get the burn accounts
    public fun get_burn_accounts(): vector<address> {
       *&get_constants().burn_accounts
    }

    public fun get_difficulty(): u64 {
      get_constants().difficulty
    }

    public fun get_mining_threshold(): u64 {
      get_constants().epoch_mining_threshold
    }


    fun get_constants(): GlobalConstants  {
      let coin_scale = 1000000; //Libra::scaling_factor<GAS::T>();
      if (Testnet::is_testnet()) {
        return GlobalConstants {
          epoch_length: 60, // seconds
          max_validator_per_epoch: 10,
          subsidy_ceiling_gas: 296,
          min_node_density: 4,
          max_node_density: 300,
          burn_accounts: Vector::singleton(0xDEADDEAD),
          difficulty: 100,
          epoch_mining_threshold: 1,
        }

      } else {
        if (StagingNet::is_staging_net()){
        return GlobalConstants {
          epoch_length: 60 * 20, // 20 mins, enough for a hard miner proof.
          max_validator_per_epoch: 300,
          subsidy_ceiling_gas: 8640000 * coin_scale,
          min_node_density: 4,
          max_node_density: 300,
          burn_accounts: Vector::singleton(0xDEADDEAD),
          difficulty: 5000000,
          epoch_mining_threshold: 1,
        } 
      } else {
          return GlobalConstants {
          epoch_length: 60 * 60 * 24, // approx 24 hours at 1.4 blocks/sec
          max_validator_per_epoch: 300, // max expected for BFT limits.
          // See LibraVMConfig for gas constants:
          // Target max gas units per transaction 100000000
          // target max block time: 2 secs
          // target transaction per sec max gas: 20
          // uses "scaled representation", since there are no decimals.
          subsidy_ceiling_gas: 8640000 * coin_scale, // subsidy amount assumes 24 hour epoch lengths. Also needs to be adjusted for coin_scale the onchain representation of human readable value.
          min_node_density: 4,
          max_node_density: 300,
          burn_accounts: Vector::singleton(0xDEADDEAD),
          difficulty: 5000000, //10 mins on macbook pro 2.5 ghz quadcore
          epoch_mining_threshold: 20,
          }
        }
      }
    }
  }
}