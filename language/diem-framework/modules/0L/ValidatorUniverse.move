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
    use 0x1::TowerState;
    use 0x1::Signer;
    use 0x1::Testnet;
    use 0x1::Vector;
    // use 0x1::FullnodeState;
    
    // resource for tracking the universe of accounts that have submitted 
    // a mined proof correctly, with the epoch number.
    struct ValidatorUniverse has key {
        validators: vector<address>
    }

    struct JailedBit has key {
        is_jailed: bool
    }

    // Genesis function to initialize ValidatorUniverse struct in 0x0.
    // This is triggered in new epoch by Configuration in Genesis.move
    // Function code: 01 Prefix: 220101
    public fun initialize(account: &signer){
      // Check for transactions sender is association
      let sender = Signer::address_of(account);
      assert(sender == CoreAddresses::DIEM_ROOT_ADDRESS(), Errors::requires_role(220101));
      move_to<ValidatorUniverse>(account, ValidatorUniverse {
          validators: Vector::empty<address>()
      });
    }

    // This function is called to add validator to the validator universe.
    // Function code: 02 Prefix: 220102
    // TODO: This is public, anyone can add themselves to the validator universe.
    public fun add_self(sender: &signer) acquires ValidatorUniverse, JailedBit {
      let addr = Signer::address_of(sender);
      
      // Miner can only add self to set if the mining is above a threshold.
      if (TowerState::is_onboarding(addr)) {
        add(sender);
      } else {      
        assert(TowerState::node_above_thresh(addr), 220102014010);
        add(sender);
      }
    }

    fun add(sender: &signer) acquires ValidatorUniverse, JailedBit {
      let addr = Signer::address_of(sender);
      let state = borrow_global<ValidatorUniverse>(CoreAddresses::DIEM_ROOT_ADDRESS());
      let (in_set, _) = Vector::index_of<address>(&state.validators, &addr);
      if (!in_set) {
        let state = borrow_global_mut<ValidatorUniverse>(CoreAddresses::DIEM_ROOT_ADDRESS());
        Vector::push_back<address>(&mut state.validators, addr);
        unjail(sender);
      }
    }

    // A simple public function to query the EligibleValidators.
    // Function code: 03 Prefix: 220103
    public fun get_eligible_validators(vm: &signer): vector<address> acquires ValidatorUniverse {
      assert(Signer::address_of(vm) == CoreAddresses::DIEM_ROOT_ADDRESS(), Errors::requires_role(220103));
      let state = borrow_global<ValidatorUniverse>(CoreAddresses::DIEM_ROOT_ADDRESS());
      *&state.validators
    }

    // Is a candidate for validation
    public fun is_in_universe(miner: address): bool acquires ValidatorUniverse {
      let state = borrow_global<ValidatorUniverse>(CoreAddresses::DIEM_ROOT_ADDRESS());
      Vector::contains<address>(&state.validators, &miner)
    }

    public fun jail(vm: &signer, validator: address) acquires JailedBit{
      assert(Signer::address_of(vm) == CoreAddresses::DIEM_ROOT_ADDRESS(), 220101014010);

      borrow_global_mut<JailedBit>(validator).is_jailed = true;
    }

    public fun unjail_self(sender: &signer) acquires JailedBit {
      // only a validator can un-jail themselves.
      let validator = Signer::address_of(sender);
      // check the node has been mining before unjailing.
      assert(TowerState::node_above_thresh(validator), 220102014010);
      unjail(sender);
    }

    fun unjail(sender: &signer) acquires JailedBit {
      let addr = Signer::address_of(sender);
      if (!exists<JailedBit>(addr)) {
        move_to<JailedBit>(sender, JailedBit { is_jailed: false });
        return
      };

      borrow_global_mut<JailedBit>(addr).is_jailed = false;
    }

    public fun exists_jailedbit(addr: address): bool {
      exists<JailedBit>(addr)
    }

    public fun is_jailed(validator: address): bool acquires JailedBit {
      if (!exists<JailedBit>(validator)) {
        return false
      };
      borrow_global<JailedBit>(validator).is_jailed
    }

    // Todo: Better name? genesis_helper_add_validator()?
    public fun genesis_helper(vm: &signer, validator: &signer) acquires ValidatorUniverse, JailedBit {
      assert(Signer::address_of(vm) == CoreAddresses::DIEM_ROOT_ADDRESS(), 220101014010);
      add(validator);
    }

    //////// TEST ////////

    public fun test_helper_add_self_onboard(vm: &signer, addr:address) acquires ValidatorUniverse {
      assert(Testnet::is_testnet(), 220116014011);
      assert(Signer::address_of(vm) == CoreAddresses::DIEM_ROOT_ADDRESS(), 220101015010);
      let state = borrow_global_mut<ValidatorUniverse>(CoreAddresses::DIEM_ROOT_ADDRESS());
      Vector::push_back<address>(&mut state.validators, addr);
    }
  }
}