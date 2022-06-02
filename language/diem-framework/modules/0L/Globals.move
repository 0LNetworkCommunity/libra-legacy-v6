///////////////////////////////////////////////////////////////////
// 0L Module
// Globals
// Error code: 0700
///////////////////////////////////////////////////////////////////

address 0x1 {

/// # Summary 
/// This module provides global variables and constants that have no specific owner 
module Globals {
    use 0x1::Testnet;
    use 0x1::Errors;
    use 0x1::StagingNet;
    use 0x1::Diem;
    use 0x1::GAS;
    
    /// Global constants determining validator settings & requirements 
    /// Some constants need to be changed based on environment; dev, testing, prod.
    /// epoch_length: The length of an epoch in seconds (~1 day for prod.) 
    /// max_validators_per_set: The maximum number of validators that can participate 
    /// subsidy_ceiling_gas: TODO I don't really know what this is
    /// vdf_difficulty: The difficulty required for VDF proofs submitting by miners 
    /// epoch_mining_thres_lower: The number of proofs that must be submitted each 
    /// epoch by a miner to remain compliant  
    struct GlobalConstants has drop {
      // For validator set.
      epoch_length: u64,
      max_validators_per_set: u64,
      subsidy_ceiling_gas: u64,
      vdf_difficulty_baseline: u64,
      vdf_security_baseline: u64,
      epoch_mining_thres_lower: u64,
      epoch_mining_thres_upper: u64,
      epoch_slow_wallet_unlock: u64,
      min_blocks_per_epoch: u64,
    }

    const COIN_SCALING_FACTOR: u64 = 1000000;

    /// Get the epoch length
    public fun get_epoch_length(): u64 {
       get_constants().epoch_length
    }

    /// Get max validator per epoch
    public fun get_max_validators_per_set(): u64 {
       get_constants().max_validators_per_set
    }

    /// Get the epoch length
    public fun get_coin_scaling_factor(): u64 {
       COIN_SCALING_FACTOR
    }

    /// Get max validator per epoch
    public fun get_subsidy_ceiling_gas(): u64 {
       get_constants().subsidy_ceiling_gas
    }

    /// Get the current vdf_difficulty
    public fun get_vdf_difficulty_baseline(): u64 {
      get_constants().vdf_difficulty_baseline
    }

    /// Get the current vdf_difficulty
    public fun get_vdf_security_baseline(): u64 {
      get_constants().vdf_security_baseline
    }


    /// Get the mining threshold 
    public fun get_epoch_mining_thres_lower(): u64 {
      get_constants().epoch_mining_thres_lower
    }

    /// Get the mining threshold 
    public fun get_epoch_mining_thres_upper(): u64 {
      get_constants().epoch_mining_thres_upper
    }

    /// Get the mining threshold 
    public fun get_unlock(): u64 {
      get_constants().epoch_slow_wallet_unlock
    }

        /// Get the mining threshold 
    public fun get_min_blocks_epoch(): u64 {
      get_constants().min_blocks_per_epoch
    }



    /// Get the constants for the current network 
    fun get_constants(): GlobalConstants {
      // let coin_scale = 1000000; // Diem::scaling_factor<GAS::T>();
      assert(COIN_SCALING_FACTOR == Diem::scaling_factor<GAS::GAS>(), Errors::invalid_argument(070001));

      if (Testnet::is_testnet()) {
        return GlobalConstants {
          epoch_length: 60, // seconds
          max_validators_per_set: 100,
          subsidy_ceiling_gas: 296 * COIN_SCALING_FACTOR,
          vdf_difficulty_baseline: 100,
          vdf_security_baseline: 512,
          epoch_mining_thres_lower: 2, //many tests depend on two proofs because the test harness already gives one at genesis to validators
          epoch_mining_thres_upper: 1000, // upper bound unlimited
          epoch_slow_wallet_unlock: 10,
          min_blocks_per_epoch: 0,
        }
      };

      if (StagingNet::is_staging_net()) {
        return GlobalConstants {
          epoch_length: 60 * 40, // 40 mins, enough for a hard miner proof.
          max_validators_per_set: 100,
          subsidy_ceiling_gas: 8640000 * COIN_SCALING_FACTOR,
          vdf_difficulty_baseline: 120000000,
          vdf_security_baseline: 512,
          epoch_mining_thres_lower: 1, // in testnet, staging, we don't want to wait too long between proofs.
          epoch_mining_thres_upper: 72, // upper bound enforced at 20 mins per proof.
          epoch_slow_wallet_unlock: 10000000,
          min_blocks_per_epoch: 1000,
        }
      } else {
        return GlobalConstants {
          epoch_length: 60 * 60 * 24, // approx 24 hours at 1.4 vdf_proofs/sec
          max_validators_per_set: 100, // max expected for BFT limits.
          // See DiemVMConfig for gas constants:
          // Target max gas units per transaction 100000000
          // target max block time: 2 secs
          // target transaction per sec max gas: 20
          // uses "scaled representation", since there are no decimals.
          subsidy_ceiling_gas: 8640000 * COIN_SCALING_FACTOR, // subsidy amount assumes 24 hour epoch lengths. Also needs to be adjusted for coin_scale the onchain representation of human readable value.
          vdf_difficulty_baseline: 120000000, // FYI approx 30 mins per proof on 2020 macbook pro 2.5 ghz quadcore
          vdf_security_baseline: 512,
          epoch_mining_thres_lower: 7, // NOTE: bootstrapping, allowance for operator error.
          epoch_mining_thres_upper: 72, // upper bound enforced at 20 mins per proof.
          epoch_slow_wallet_unlock: 1000 * COIN_SCALING_FACTOR, // approx 10 years for largest accounts in genesis.
          min_blocks_per_epoch: 10000,
        }
      }
    }

  }
}