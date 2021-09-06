///////////////////////////////////////////////////////////////////
// 0L Module
// Globals
// Error code: 0700
///////////////////////////////////////////////////////////////////

address 0x1 {

// TODO: This module is not complete, as Metadata has not been implemented.

/// # Summary 
/// This module provides global variables and constants that have no specific owner 
module Globals {
    use 0x1::Vector;
    use 0x1::Testnet;
    use 0x1::Errors;
    use 0x1::StagingNet;
    use 0x1::Diem;
    use 0x1::GAS;
    
    /// Global constants determining validator settings & requirements 
    /// Some constants need to changed based on environment; dev, testing, prod.
    /// epoch_length: The length of an epoch in seconds (~1 day for prod.) 
    /// max_validator_per_epoch: The maximum number of validators that can participate 
    /// subsidy_ceiling_gas: TODO I don't really know what this is
    /// min_node_density: The minimum number of nodes that can receive a subsidy 
    /// max_node_density: The maximum number of nodes that can receive a subsidy 
    /// burn_accounts: The address to which burnt tokens should be sent 
    /// difficulty: The difficulty required for VDF proofs submitting by miners 
    /// epoch_mining_threshold: The number of proofs that must be submitted each 
    ///       epoch by a miner to remain compliant  
    struct GlobalConstants has drop {
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


    ////////////////////
    //// Constants ////
    ///////////////////

    /// Get the epoch length
    public fun get_epoch_length(): u64 {
       get_constants().epoch_length
    }

    /// Get max validator per epoch
    public fun get_max_validator_per_epoch(): u64 {
       get_constants().max_validator_per_epoch
    }

    /// Get max validator per epoch
    public fun get_subsidy_ceiling_gas(): u64 {
       get_constants().subsidy_ceiling_gas
    }

    /// Get max validator per epoch
    public fun get_max_node_density(): u64 {
       get_constants().max_node_density
    }

    /// Get the burn accounts
    public fun get_burn_accounts(): vector<address> {
       *&get_constants().burn_accounts
    }

    /// Get the current difficulty
    public fun get_difficulty(): u64 {
      get_constants().difficulty
    }

    /// Get the mining threshold 
    public fun get_mining_threshold(): u64 {
      get_constants().epoch_mining_threshold
    }

    /// get the constants for the current network 
    fun get_constants(): GlobalConstants {
      
      let coin_scale = 1000000; //Diem::scaling_factor<GAS::T>();
      assert(coin_scale == Diem::scaling_factor<GAS::GAS>(), Errors::invalid_argument(070001));

      if (Testnet::is_testnet()) {
        return GlobalConstants {
          epoch_length: 60, // seconds
          max_validator_per_epoch: 10,
          subsidy_ceiling_gas: 296 * coin_scale,
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
          // See DiemVMConfig for gas constants:
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