///////////////////////////////////////////////////////////////////////////
// 0L Module
// ValidatorUniverse
///////////////////////////////////////////////////////////////////////////
// Stores all the validators who submitted a vdf proof.
// File Prefix for errors: 2201
///////////////////////////////////////////////////////////////////////////

address 0x1 {
  module ValidatorUniverse {

    use 0x1::Vector;
    use 0x1::Signer;
    use 0x1::Option::{Self, Option};
    use 0x1::CoreAddresses;

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
    public fun initialize(account: &signer){
      // Check for transactions sender is association
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 220101014010);

      move_to<ValidatorUniverse>(account, ValidatorUniverse {
          validators: Vector::empty<ValidatorEpochInfo>()
      });
    }

    // This function is called to add validator to the validator universe.
    // Function code: 02 Prefix: 220102
    public fun add_validator(sender: &signer) acquires ValidatorUniverse {
      let addr = Signer::address_of(sender);
      let collection = borrow_global_mut<ValidatorUniverse>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      assert(!validator_exists_in_universe(collection, addr), 220101015010);
      Vector::push_back<ValidatorEpochInfo>(
        &mut collection.validators,
        ValidatorEpochInfo{
        validator_address: addr,
        weight: 1
      });
    }

    // 0L: A simple public function to query the EligibleValidators.
    // Only system addresses should be able to access this function
    // Eligible validators are all those nodes who have mined a VDF proof at any time.
    // TODO (nelaturuk): Wonder if this helper is necessary since it is just stripping the Validator Universe vector of other fields.
    // Function code: 03 Prefix: 220103
    public fun get_eligible_validators(account: &signer) : vector<address> acquires ValidatorUniverse {
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 220101014010);

      let eligible_validators = Vector::empty<address>();
      // Create a vector with all eligible validator addresses
      // Get all the data from the ValidatorUniverse resource stored in the association/system address.
      let collection = borrow_global<ValidatorUniverse>(CoreAddresses::LIBRA_ROOT_ADDRESS());

      let i = 0;
      let validator_list = &collection.validators;
      let len = Vector::length<ValidatorEpochInfo>(validator_list);
      while (i < len) {
          Vector::push_back(&mut eligible_validators, Vector::borrow<ValidatorEpochInfo>(validator_list, i).validator_address);
          i = i + 1;
      };
      eligible_validators
    }

    // Simple convenience function to lookup if a validator exists in ValidatorUniverse structure.
    // Function code: 04 Prefix: 220104
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

    // This function is the Proof of Weight. This is what calculates the values
    // for the consensus vote power, which will be used by Reconfiguration to call LibraSystem::bulk_update_validators.
    // Function code: 05 Prefix: 220105
    public fun proof_of_weight(account: &signer, addr: address, is_validator_in_current_epoch: bool): u64 acquires ValidatorUniverse {
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 22010105014010);

      //1. borrow the Validator's ValidatorEpochInfo
      // Get the validator
      let collection =  borrow_global_mut<ValidatorUniverse>(CoreAddresses::LIBRA_ROOT_ADDRESS());

      // Getting index of the validator
      let index_vec = get_validator_index_(&collection.validators, addr);
      assert(Option::is_some(&index_vec), 220105022040);
      let index = *Option::borrow(&index_vec);

      let validator_list = &mut collection.validators;
      let validatorInfo = Vector::borrow_mut<ValidatorEpochInfo>(validator_list, index);


      // Weight is metric based on: The number of epochs the miners have been mining for
      let weight = 1;

      // If the validator mined in current epoch, increment it's weight.
      if(is_validator_in_current_epoch)
        weight = validatorInfo.weight + 1;

      validatorInfo.weight = weight;
      weight
    }

    // Get the index of the validator by address in the `validators` vector
    fun get_validator_index_(validators: &vector<ValidatorEpochInfo>, addr: address): Option<u64>{
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
    fun get_validator(addr: address): ValidatorEpochInfo acquires ValidatorUniverse{

      let validators = &borrow_global_mut<ValidatorUniverse>(CoreAddresses::LIBRA_ROOT_ADDRESS()).validators;
      let size = Vector::length(validators);

      let i = 0;
      while (i < size) {
          let validator_info_ref = Vector::borrow(validators, i);
          if (validator_info_ref.validator_address == addr) {
              return *validator_info_ref
          };
          i = i + 1;
      };

      return ValidatorEpochInfo{
        validator_address: {{CoreAddresses::LIBRA_ROOT_ADDRESS()}},
        weight: 0
      }
    }

    // Function code: 06 Prefix: 220106
    public fun get_validator_weight(account: &signer, addr: address): u64 acquires ValidatorUniverse{
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), 220106014010);

      let validatorInfo = get_validator(addr);

      // Validator not in universe error
      assert(validatorInfo.validator_address != CoreAddresses::LIBRA_ROOT_ADDRESS(), 220106022040);
      return validatorInfo.weight
    }
  }
}