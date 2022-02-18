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

    // triggered once per epoch
    struct Ancestry has key {
      // the full tree back to genesis set
      tree: vector<address>,
      // the algorithm for family may change over time
      family: address,
    }

    public fun init(onboarder: &signer, new_account: &signer ) acquires Ancestry {
      let parent = Signer::address_of(onboarder);
      let child = Signer::address_of(new_account);
      print(&1);

      if (!exists<Ancestry>(parent)) return;

      let parent_state = borrow_global_mut<Ancestry>(parent);
      let parent_tree = *&parent_state.tree;
      print(&2);
      if (Vector::length<address>(&parent_tree) == 0) return;
      
      let earliest = *Vector::borrow(&parent_tree, 0);
      print(&3);
      // push the onboarder onto the inherited tree.
      // for compression, we don't need the tree to include yourself.
      // but it needs to be extended.

      Vector::push_back(&mut parent_tree, parent);

      if (!exists<Ancestry>(child)) {
        move_to<Ancestry>(new_account, Ancestry {
          tree: parent_tree, 
          family: earliest,
        })
      }

    }

    public fun get_tree(addr: address): vector<address> acquires Ancestry {
      *&borrow_global<Ancestry>(addr).tree
    }

    public fun migrate(sender: &signer) {
      let a = Signer::address_of(sender);
      print(&a);

    }
  }
}