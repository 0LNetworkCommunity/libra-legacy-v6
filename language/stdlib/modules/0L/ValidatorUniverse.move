///////////////////////////////////////////////////////////////////////////
// 0L Module
// ValidatorUniverse
///////////////////////////////////////////////////////////////////////////
// Stores all the validators who submitted a vdf proof.
// File Prefix for errors: 2201
///////////////////////////////////////////////////////////////////////////

address 0x1 {
  module ValidatorUniverse {
    use 0x1::CoreAddresses;
    use 0x1::Errors;
    use 0x1::Signer;
    use 0x1::Vector;

    // resource for tracking the universe of accounts that have submitted a mined proof correctly, with the epoch number.
    resource struct ValidatorUniverse {
        validators: vector<address>
    }

    // function to initialize ValidatorUniverse in genesis.
    // This is triggered in new epoch by Configuration in Genesis.move
    // Function code: 01 Prefix: 220101
    public fun initialize(account: &signer){
      // Check for transactions sender is association
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::LIBRA_ROOT_ADDRESS(), Errors::requires_role(220101));
      move_to<ValidatorUniverse>(account, ValidatorUniverse {
          validators: Vector::empty<address>()
      });
    }

    // This function is called to add validator to the validator universe.
    // Function code: 02 Prefix: 220102
    public fun add_validator(sender: &signer) acquires ValidatorUniverse {
      let addr = Signer::address_of(sender);
      let state = borrow_global_mut<ValidatorUniverse>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      let (in_set, _) = Vector::index_of<address>(&state.validators, &addr);
      if (!in_set) {
        Vector::push_back<address>(&mut state.validators, addr);
      }
    }

    // A simple public function to query the EligibleValidators.
    // Function code: 03 Prefix: 220103
    public fun get_eligible_validators(vm: &signer): vector<address> acquires ValidatorUniverse {
      assert(Signer::address_of(vm) == CoreAddresses::LIBRA_ROOT_ADDRESS(), Errors::requires_role(220103));
      let state = borrow_global<ValidatorUniverse>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      *&state.validators
    }

    // Is a candidate for validation
    public fun is_in_universe(miner: address): bool acquires ValidatorUniverse {
      let state = borrow_global<ValidatorUniverse>(CoreAddresses::LIBRA_ROOT_ADDRESS());
      Vector::contains<address>(&state.validators, &miner)
    }
  }
}