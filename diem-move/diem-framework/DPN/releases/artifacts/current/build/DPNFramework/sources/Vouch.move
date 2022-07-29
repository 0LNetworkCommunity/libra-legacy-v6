/////////////////////////////////////////////////////////////////////////
// 0L Module
// Vouce Module
// Error code: 
/////////////////////////////////////////////////////////////////////////

address DiemFramework {
  module Vouch {
    use Std::Signer;
    use Std::Vector;
    use DiemFramework::ValidatorUniverse;
    use DiemFramework::DiemSystem;
    use DiemFramework::Ancestry;
    use DiemFramework::Testnet;
    use DiemFramework::StagingNet;
    use DiemFramework::CoreAddresses;

    // triggered once per epoch
    struct Vouch has key {
      vals: vector<address>,
    }

    // init the struct on a validators account.
    public fun init(new_account_sig: &signer ) {
      let acc = Signer::address_of(new_account_sig);

      if (ValidatorUniverse::is_in_universe(acc) && !is_init(acc)) {
        move_to<Vouch>(new_account_sig, Vouch {
            vals: Vector::empty(), 
          });
      }
    }

    public fun is_init(acc: address ):bool {
      exists<Vouch>(acc)
    }

    public fun vouch_for(buddy: &signer, val: address) acquires Vouch {
      let buddy_acc = Signer::address_of(buddy);
      assert!(buddy_acc!=val, 12345); // TODO: Error code.

      if (!ValidatorUniverse::is_in_universe(buddy_acc)) return;
      if (!exists<Vouch>(val)) return;

      let v = borrow_global_mut<Vouch>(val);
      Vector::push_back<address>(&mut v.vals, buddy_acc);
    }

    public fun vm_migrate(vm: &signer, val: address, buddy_list: vector<address>) acquires Vouch {
      CoreAddresses::assert_vm(vm);

      if (!ValidatorUniverse::is_in_universe(val)) return;
      if (!exists<Vouch>(val)) return;

      let v = borrow_global_mut<Vouch>(val);

      // take self out of list
      let (is_found, i) = Vector::index_of(&buddy_list, &val);

      if (is_found) {
        Vector::swap_remove<address>(&mut buddy_list, i);
      };
      
      v.vals = buddy_list;
    }

    public fun get_buddies(val: address): vector<address> acquires Vouch{
      if (is_init(val)) {
        return *&borrow_global<Vouch>(val).vals
      };
      Vector::empty<address>()
    }

    public fun buddies_in_set(val: address): vector<address> acquires Vouch {
      let current_set = DiemSystem::get_val_set_addr();
      if (!exists<Vouch>(val)) return Vector::empty<address>();

      let v = borrow_global<Vouch>(val);

      let buddies_in_set = Vector::empty<address>();
      let  i = 0;
      while (i < Vector::length<address>(&v.vals)) {
        let a = Vector::borrow<address>(&v.vals, i);
        if (Vector::contains(&current_set, a)) {
          Vector::push_back(&mut buddies_in_set, *a);
        };
        i = i + 1;
      };

      buddies_in_set
    }

    public fun unrelated_buddies(val: address): vector<address> acquires Vouch {
      // start our list empty
      let unrelated_buddies = Vector::empty<address>();

      // find all our buddies in this validator set
      let buddies_in_set = buddies_in_set(val);
      let len = Vector::length<address>(&buddies_in_set);
      let  i = 0;
      while (i < len) {
      
        let target_acc = Vector::borrow<address>(&buddies_in_set, i);

        // now loop through all the accounts again, and check if this target
        // account is related to anyone.
        let  k = 0;
        while (k < Vector::length<address>(&buddies_in_set)) {
          let comparison_acc = Vector::borrow(&buddies_in_set, k);
          // skip if you're the same person
          if (comparison_acc != target_acc) {
            // check ancestry algo
            let (is_fam, _) = Ancestry::is_family(*comparison_acc, *target_acc);
            if (!is_fam) {
              if (!Vector::contains(&unrelated_buddies, target_acc)) {
                Vector::push_back<address>(&mut unrelated_buddies, *target_acc)
              }
            }
          };
          k = k + 1;
        };
      
        // if (Vector::contains(&current_set, a)) {
        //   Vector::push_back(&mut buddies_in_set, *a);
        // };
        i = i + 1;
      };

      unrelated_buddies
    }

    public fun unrelated_buddies_above_thresh(val: address): bool acquires Vouch{
      if (Testnet::is_testnet() || StagingNet::is_staging_net()) {
        return true
      };

      let len = Vector::length(&unrelated_buddies(val));
      (len > 3) // TODO: move to Globals
    }
  }
}