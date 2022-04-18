/////////////////////////////////////////////////////////////////////////
// 0L Module
// Ancestry Module
// Error code: 
/////////////////////////////////////////////////////////////////////////

address 0x1 {
  module Ancestry {
    use 0x1::Signer;
    use 0x1::Vector;
    use 0x1::Debug::print;
    use 0x1::CoreAddresses;
    // triggered once per epoch
    struct Ancestry has key {
      // the full tree back to genesis set
      tree: vector<address>,
    }
    // this is limited to onboarding.
    // TODO: limit this with `friend` of DiemAccount module.
    public fun init(new_account_sig: &signer, onboarder_sig: &signer ) acquires Ancestry{
        let parent = Signer::address_of(onboarder_sig);
        set_tree(new_account_sig, parent);

    }

    // private. The user should NEVER be able to change ancestry through a transaction.

    fun set_tree(new_account_sig: &signer, parent: address ) acquires Ancestry {
      let child = Signer::address_of(new_account_sig);
      print(&1);
      let new_tree = Vector::empty<address>(); 

      // get the parent's ancestry if initialized.
      // if not then this is an edge case possibly a migration error, and we'll just use the parent.
      if (exists<Ancestry>(parent)) {
        let parent_state = borrow_global_mut<Ancestry>(parent);
        let parent_tree = *&parent_state.tree;
        print(&2);
        if (Vector::length<address>(&parent_tree) > 0) {
          Vector::append(&mut new_tree, parent_tree);
        };
        print(&3);
      };

      // add the parent to the tree
      Vector::push_back(&mut new_tree, parent);

      if (!exists<Ancestry>(child)) {
        move_to<Ancestry>(new_account_sig, Ancestry {
          tree: new_tree, 
        })
      } else {
        // this is only for migration cases.
        let child_ancestry = borrow_global_mut<Ancestry>(child);
        child_ancestry.tree = new_tree;
      }
    }

    public fun get_tree(addr: address): vector<address> acquires Ancestry {
      *&borrow_global<Ancestry>(addr).tree
    }

    public fun is_family(left: address, right: address): (bool, address) acquires Ancestry {
      let left_tree = *&borrow_global<Ancestry>(left).tree;
      let right_tree = *&borrow_global<Ancestry>(right).tree;
      
      let is_family = false;
      let common_ancestor = @0x0;

      let i = 0;
      while (i < Vector::length<address>(&left_tree)) {
        let family_addr = Vector::borrow(&left_tree, i);
        if (Vector::contains(&right_tree, family_addr)) {
          is_family = true;
          common_ancestor = *family_addr;
          break
        }
      };

      (is_family, common_ancestor)
    }

    // admin migration. Needs the signer object for both VM and child to prevent changes.
    // us also a private function so that it cannot be called by scripts, only by VM in a writeset mode.
    fun migrate(vm: &signer, child_sig: &signer, parent: address) acquires Ancestry {
      CoreAddresses::assert_vm(vm);
      set_tree(child_sig, parent)

    }
  }
}