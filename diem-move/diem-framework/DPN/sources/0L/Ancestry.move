/////////////////////////////////////////////////////////////////////////
// 0L Module
// Ancestry Module
// Error code: 
/////////////////////////////////////////////////////////////////////////

address DiemFramework {
  module Ancestry {
    use Std::Signer;
    use Std::Vector;
    use Std::Option::{Self, Option};
    // use DiemFramework::Debug::print;
    use DiemFramework::CoreAddresses;

    // triggered once per epoch
    struct Ancestry has key {
      // the full tree back to genesis set
      tree: vector<address>,
    }
  
    // this is limited to onboarding.
    // TODO: limit this with `friend` of DiemAccount module.
    public fun init(new_account_sig: &signer, onboarder_sig: &signer ) acquires Ancestry{
        // print(&100100);
        let parent = Signer::address_of(onboarder_sig);
        set_tree(new_account_sig, parent);
    }

    // private. The user should NEVER be able to change ancestry through a transaction.
    fun set_tree(new_account_sig: &signer, parent: address ) acquires Ancestry {
      let child = Signer::address_of(new_account_sig);
        // print(&100200);
      let new_tree = Vector::empty<address>(); 

      // get the parent's ancestry if initialized.
      // if not then this is an edge case possibly a migration error,
      // and we'll just use the parent.
      if (exists<Ancestry>(parent)) {
        let parent_state = borrow_global_mut<Ancestry>(parent);
        let parent_tree = *&parent_state.tree;
        // print(&100210);
        if (Vector::length<address>(&parent_tree) > 0) {
          Vector::append(&mut new_tree, parent_tree);
        };
        // print(&100220);
      };

      // add the parent to the tree
      Vector::push_back(&mut new_tree, parent);
        // print(&100230);

      if (!exists<Ancestry>(child)) {
        move_to<Ancestry>(new_account_sig, Ancestry {
          tree: new_tree, 
        });
        // print(&100240);

      } else {
        // this is only for migration cases.
        let child_ancestry = borrow_global_mut<Ancestry>(child);
        child_ancestry.tree = new_tree;
        // print(&100250);

      };
      // print(&100260);

    }

    public fun get_tree(addr: address): vector<address> acquires Ancestry {
      if (exists<Ancestry>(addr)) {
        *&borrow_global<Ancestry>(addr).tree
      } else {
        Vector::empty()
      }
      
    }

    // checks if two addresses have an intersecting permission tree
    // will return true, and the common ancestor at the intersection.
    public fun is_family(left: address, right: address): (bool, address) acquires Ancestry {
      let is_family = false;
      let common_ancestor = @0x0;
      // // print(&100300);
      // // print(&exists<Ancestry>(left));
      // // print(&exists<Ancestry>(right));

      // if (exists<Ancestry>(left) && exists<Ancestry>(right)) {
        // if tree is empty it will still work.
        // // print(&100310);
        let left_tree = get_tree(left);
        // // print(&100311);
        let right_tree = get_tree(right);

        // // print(&100320);

        // check for direct relationship.
        if (Vector::contains(&left_tree, &right)) return (true, right);
        if (Vector::contains(&right_tree, &left)) return (true, left);
        
        // // print(&100330);
        let i = 0;
        // check every address on the list if there are overlaps.
        while (i < Vector::length<address>(&left_tree)) {
          // // print(&100341);
          let family_addr = Vector::borrow(&left_tree, i);
          if (Vector::contains(&right_tree, family_addr)) {
            is_family = true;
            common_ancestor = *family_addr;
            // // print(&100342);
            break
          };
          i = i + 1;
        };
        // // print(&100350);
      // };
      // // print(&100360);
      (is_family, common_ancestor)
    }

    public fun is_family_one_in_list(left: address, list: &vector<address>):(bool, Option<address>, Option<address>) acquires Ancestry {
      let k = 0;
      while (k < Vector::length(list)) {
        let right = Vector::borrow(list, k);
        let (fam, _) = is_family(left, *right);
        if (fam) { 
          return (true, Option::some(left), Option::some(*right))
        };
        k = k + 1;
      };

      (false, Option::none(), Option::none())
    }

    public fun any_family_in_list(addr_vec: vector<address>):(bool, Option<address>, Option<address>) acquires Ancestry  {
      let i = 0;
      while (Vector::length(&addr_vec) > 1) {
        let left = Vector::pop_back(&mut addr_vec);

        let (fam, left_opt, right_opt) = is_family_one_in_list(left, &addr_vec);
        if (fam) {
          return (fam, left_opt, right_opt)
        };

        i = i + 1;
      };

      (false, Option::none(), Option::none())
    }

    // admin migration. Needs the signer object for both VM and child to prevent changes.
    public fun migrate(
      vm: &signer,
      child_sig: &signer,
      migrate_tree: vector<address>
    ) acquires Ancestry {
      CoreAddresses::assert_vm(vm);
      let child = Signer::address_of(child_sig);

      if (!exists<Ancestry>(child)) {
        move_to<Ancestry>(child_sig, Ancestry {
          tree: migrate_tree, 
        });
        // print(&100240);

      } else {
        // this is only for migration cases.
        let child_ancestry = borrow_global_mut<Ancestry>(child);
        child_ancestry.tree = migrate_tree;
        // print(&100250);

      };
    }
  }
}