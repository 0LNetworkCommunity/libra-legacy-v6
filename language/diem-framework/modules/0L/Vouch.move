/////////////////////////////////////////////////////////////////////////
// 0L Module
// Vouce Module
// Error code: 
/////////////////////////////////////////////////////////////////////////

address 0x1 {
  module Vouch {
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::ValidatorUniverse;
    use 0x1::DiemSystem;
    use 0x1::Ancestry;
    use 0x1::Testnet;
    use 0x1::StagingNet;
    use 0x1::CoreAddresses;

    use 0x1::Debug::print;

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
      assert(buddy_acc!=val, 12345); // TODO: Error code.

      if (!ValidatorUniverse::is_in_universe(buddy_acc)) return;
      if (!exists<Vouch>(val)) return;

      let v = borrow_global_mut<Vouch>(val);
      if (!Vector::contains(&v.vals, &buddy_acc)) { // prevent duplicates
        Vector::push_back<address>(&mut v.vals, buddy_acc);
      }
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

        // now loop through all the accounts again, and check if this target account is related to anyone.
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
      print(&222222);
      if (Testnet::is_testnet() || StagingNet::is_staging_net()) {
        return true
      };
      print(&22222200001);

      if (!exists<Vouch>(val)) return false;
      print(&22222200002);

      let len = Vector::length(&unrelated_buddies(val));
      print(&22222200003);

      (len >= 4) // TODO: move to Globals
    }
  }
}