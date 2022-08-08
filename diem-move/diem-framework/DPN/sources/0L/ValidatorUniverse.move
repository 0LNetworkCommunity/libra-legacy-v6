///////////////////////////////////////////////////////////////////////////
// 0L Module
// ValidatorUniverse
///////////////////////////////////////////////////////////////////////////
// Stores all the validators who submitted a vdf proof.
// File Prefix for errors: 2201
///////////////////////////////////////////////////////////////////////////

address DiemFramework {
  module ValidatorUniverse {
    use Std::Errors;
    use DiemFramework::TowerState;
    use Std::Signer;
    use DiemFramework::Testnet;
    use Std::Vector;
    // use DiemFramework::FullnodeState;
    
    // resource for tracking the universe of accounts that have submitted 
    // a mined proof correctly, with the epoch number.
    struct ValidatorUniverse has key {
        validators: vector<address>
    }

    // deprecated
    struct JailedBit has key {
        is_jailed: bool
    }

    // Genesis function to initialize ValidatorUniverse struct in 0x0.
    // This is triggered in new epoch by Configuration in Genesis.move
    // Function code: 01 Prefix: 220101
    public fun initialize(account: &signer){
      // Check for transactions sender is association
      let sender = Signer::address_of(account);
      assert!(sender == @DiemRoot, Errors::requires_role(220101));
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
        assert!(TowerState::node_above_thresh(addr), 220102014010);
        add(sender);
      }
    }

    fun add(sender: &signer) acquires ValidatorUniverse, JailedBit {
      let addr = Signer::address_of(sender);
      let state = borrow_global<ValidatorUniverse>(@DiemRoot);
      let (in_set, _) = Vector::index_of<address>(&state.validators, &addr);
      if (!in_set) {
        let state = borrow_global_mut<ValidatorUniverse>(@DiemRoot);
        Vector::push_back<address>(&mut state.validators, addr);
        unjail(sender);
      }
    }

    // Permissions: Public, Anyone.
    // Can only remove self from validator list.
    public fun remove_self(validator: &signer) acquires ValidatorUniverse {
      let val = Signer::address_of(validator);
      let state = borrow_global<ValidatorUniverse>(@DiemRoot);
      let (in_set, index) = Vector::index_of<address>(&state.validators, &val);
      if (in_set) {
         let state = borrow_global_mut<ValidatorUniverse>(@DiemRoot);
        Vector::remove<address>(&mut state.validators, index);
      }
    }

    // A simple public function to query the EligibleValidators.
    // Function code: 03 Prefix: 220103
    public fun get_eligible_validators(): vector<address> acquires ValidatorUniverse {
      let state = borrow_global<ValidatorUniverse>(@DiemRoot);
      *&state.validators
    }

    // Is a candidate for validation
    public fun is_in_universe(addr: address): bool acquires ValidatorUniverse {
      let state = borrow_global<ValidatorUniverse>(@DiemRoot);
      Vector::contains<address>(&state.validators, &addr)
    }

    public fun jail(vm: &signer, validator: address) acquires JailedBit{
      assert!(Signer::address_of(vm) == @DiemRoot, 220101014010);
      assert!(exists<JailedBit>(validator), 220101014011);
      borrow_global_mut<JailedBit>(validator).is_jailed = true;
    }

    public fun unjail_self(sender: &signer) acquires JailedBit {
      // only a validator can un-jail themselves.
      let validator = Signer::address_of(sender);
      // check the node has been mining before unjailing.
      assert!(TowerState::node_above_thresh(validator), 220101014013);
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
      assert!(Signer::address_of(vm) == @DiemRoot, 220101014010);
      add(validator);
    }

    //////// TEST ////////

    public fun test_helper_add_self_onboard(vm: &signer, addr:address) acquires ValidatorUniverse {
      assert!(Testnet::is_testnet(), 220101014014);
      assert!(Signer::address_of(vm) == @DiemRoot, 220101015010);
      let state = borrow_global_mut<ValidatorUniverse>(@DiemRoot);
      Vector::push_back<address>(&mut state.validators, addr);
    }
  }
}