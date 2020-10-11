///////////////////////////////////////////////////////////////////////////
// 0L Module
// ValidatorUniverse
///////////////////////////////////////////////////////////////////////////
// Stores all the validators who submitted a vdf proof.
// File Prefix for errors: 2201
///////////////////////////////////////////////////////////////////////////

address 0x0 {
  module ValidatorUniverse {

    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::Signer;
    use 0x0::Option;
    use 0x0::LibraTimestamp;



    struct ValidatorEpochInfo {
        validator_address: address,
        weight: u64
    }

    // resource for tracking the universe of accounts that have submitted a mined proof correctly, with the epoch number.
    resource struct ValidatorUniverse {
        validators: vector<ValidatorEpochInfo>
    }

    // function to initialize ValidatorUniverse in genesis.
    // This is triggered in new epoch by Configuration in Genesis.move
    // Function code: 01 Prefix: 220101
    // Permissions: PUBLIC, VM ONLY, GENESIS only
    public fun initialize(account: &signer){
      // Check for transactions sender is association
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 220101014010);
      Transaction::assert(LibraTimestamp::is_genesis(), 220101024010);


      move_to<ValidatorUniverse>(account, ValidatorUniverse {
          validators: Vector::empty<ValidatorEpochInfo>()
      });
    }

    // This function is called to add validator to the validator universe.
    // Function code: 02 Prefix: 220102
    
    // TODO: #239 ValidatorUniverse add_validator should restrict who can add a validator.
    public fun add_validator(addr: address) acquires ValidatorUniverse {
      let collection = borrow_global_mut<ValidatorUniverse>(0x0);

      if(!validator_exists_in_universe(collection, addr)) {
        Vector::push_back<ValidatorEpochInfo>(
          &mut collection.validators,
          ValidatorEpochInfo {
            validator_address: addr,
            weight: 1
          }
        );
      }
    }


    // 0L: Eligible validators are all those nodes who have mined a VDF proof at any time.
    // TODO: Is this helper necessary since it is just stripping the Validator Universe vector of other fields.
    // Function code: 03 Prefix: 220103
    // Permissions: PUBLIC, VM ONLY.
    public fun get_eligible_validators(account: &signer) : vector<address> acquires ValidatorUniverse {
      let sender = Signer::address_of(account);
      Transaction::assert(sender == 0x0, 220103014010);

      let eligible_validators = Vector::empty<address>();
      // Create a vector with all eligible validator addresses
      // Get all the data from the ValidatorUniverse resource stored in the association/system address.
      let collection = borrow_global<ValidatorUniverse>(0x0);

      let i = 0;
      let validator_list = &collection.validators;
      let len = Vector::length<ValidatorEpochInfo>(validator_list);

      while (i < len) {
          Vector::push_back(&mut eligible_validators, Vector::borrow<ValidatorEpochInfo>(validator_list, i).validator_address);
          i = i + 1;
      };

      eligible_validators
    }

    // Convenience function to lookup if a validator exists in ValidatorUniverse structure.
    // Function code: 04 Prefix: 220104
    // Permissions: private
    fun validator_exists_in_universe(validatorUniverse: &ValidatorUniverse, addr: address): bool {
      let i = 0;
      let validator_list = &validatorUniverse.validators;
      let len = Vector::length<ValidatorEpochInfo>(validator_list);
      while (i < len) {
          if (Vector::borrow<ValidatorEpochInfo>(validator_list, i).validator_address == addr) return true;
          i = i + 1;
      };
      false
    }
    
    // // This function is the Proof of Weight. This is what calculates the values
    // // for the consensus vote power, which will be used by Reconfiguration to call LibraSystem::bulk_update_validators.
    // // Function code: 05 Prefix: 220105
    // // Permissions: PUBLIC, VM ONLY.
    // public fun proof_of_weight(addr: address, is_validator_in_current_epoch: bool): u64 acquires ValidatorUniverse {
    //   let sender = Transaction::sender();
    //   Transaction::assert(sender == 0x0, 22010105014010);

    //   //1. borrow the Validator's ValidatorEpochInfo
    //   // Get the validator
    //   let collection =  borrow_global_mut<ValidatorUniverse>(0x0);

    //   // Getting index of the validator
    //   let index_vec = get_validator_index(&collection.validators, addr);
    //   Transaction::assert(Option::is_some(&index_vec), 220105022040);
    //   let index = *Option::borrow(&index_vec);

    //   let validator_list = &mut collection.validators;
    //   let validatorInfo = Vector::borrow_mut<ValidatorEpochInfo>(validator_list, index);


    //   // Weight is metric based on: The number of epochs the miners have been mining for
    //   let weight = 1;

    //   // If the validator mined in current epoch, increment its weight.
    //   if(is_validator_in_current_epoch) {
    //     weight = validatorInfo.weight + 1;
    //   };

    //   validatorInfo.weight = weight;
    //   weight
    // }


    // //TODO: deprecated
    // // Function code: 06 Prefix: 220106
    // // Permissions: PUBLIC, SIGNER.
    // public fun get_validator_weight(addr: address): u64 acquires ValidatorUniverse {
    //   // let sender = Transaction::sender();
    //   // Transaction::assert(
    //   //   sender == 0x0 || sender == addr
    //   //   , 220106014010);

    //   let validatorInfo = get_validator(addr);

    //   // Validator not in universe error
    //   Transaction::assert(validatorInfo.validator_address != 0x0, 220106022040);
    //   return validatorInfo.weight
    // }

    // Get the index of the validator by address in the `validators` vector
    // Permissions: private.

    fun get_validator_index(validators: &vector<ValidatorEpochInfo>, addr: address): Option::T<u64>{
      let size = Vector::length(validators);

      let i = 0;
      while (i < size) {
          let validator_info_ref = Vector::borrow(validators, i);
          if (validator_info_ref.validator_address == addr) {
              return Option::some(i)
          };
          i = i + 1;
      };

      return Option::none()
    }

    // Get the validatorInfo by address in the `validators` vector
    // Permissions: private.
    fun get_validator(addr: address): ValidatorEpochInfo acquires ValidatorUniverse{

      let validators = &borrow_global_mut<ValidatorUniverse>(0x0).validators;
      let size = Vector::length(validators);

      let i = 0;
      while (i < size) {
          let validator_info_ref = Vector::borrow(validators, i);
          if (validator_info_ref.validator_address == addr) {
              return *validator_info_ref
          };
          i = i + 1;
      };

      //TODO: wouldn't it be better to error, if there is no address found?
      return ValidatorEpochInfo{
        validator_address: {{0x0}},
        weight: 0
      }
    }

    // Check the liveness of the validator in the previous epoch
    // Function code: 07 Prefix: 220107
    // Permissions: PUBLIC, VM ONLY.
    // public fun check_if_active_validator(addr: address, epoch_length: u64, current_block_height: u64): bool {
    //   Transaction::assert(Transaction::sender() == 0x0, 220107014010);
    //   // Calculate the window in which we are evaluating the performance of validators.
    //   // start and effective end block height for the current epoch
    //   // End block for analysis happens a few blocks before the block boundar since not all blocks will be committed to all nodes at the end of the boundary.
    //   let start_block_height = 1;
    //   if (current_block_height > Globals::get_epoch_length()) {
    //     start_block_height = current_block_height - epoch_length;
    //   };

    //   let adjusted_end_block_height = current_block_height - Globals::get_epoch_boundary_buffer();

    //   let blocks_in_window = adjusted_end_block_height - start_block_height;

    //   // Calculating liveness threshold which is signing 66% of the blocks in epoch.
    //   // Note that nodes in hotstuff stops voting after 2/3 consensus has been reached, and skip to next block.
    //   let threshold_signing = FixedPoint32::multiply_u64(blocks_in_window , FixedPoint32::create_from_rational(66, 100));

    //   let block_signed_by_validator = Stats::node_heuristics(addr, start_block_height, adjusted_end_block_height);

    //   if (block_signed_by_validator < threshold_signing) {
    //       return false
    //   };

    //   true
    // }

  }
}
