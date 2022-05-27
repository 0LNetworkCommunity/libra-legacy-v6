// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 1
//! account: bob, 1000000, 0, validator
// CAROL is CASE 1
//! account: carol, 1000000, 0, validator
// DAVE is CASE 1
//! account: dave, 1000000, 0, validator
// EVE is CASE 3
//! account: eve, 1000000, 0, validator
// FRANK is CASE 1
//! account: frank, 1000000, 0, validator
// GERTIE is CASE 1
//! account: gertie, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Vector;
    use 0x1::NodeWeight;
    use 0x1::Jail;
    use 0x1::Debug::print;

    fun main(vm: signer) {
      
      let sorted_val_universe = NodeWeight::get_sorted_vals();
      let (_is_found, idx) = Vector::index_of(&sorted_val_universe, &@{{eve}});
      assert(idx == 4, 735701);

      let (_is_found, idx) = Vector::index_of(&sorted_val_universe, &@{{eve}});

      assert(idx == 4, 735702);


      print(&idx);

      let jail_sort = Jail::sort_by_jail(*&sorted_val_universe);
      let (_is_found, idx) = Vector::index_of(&jail_sort, &@{{eve}});
      print(&idx);

      Jail::jail(&vm, @{{eve}});
      assert(Jail::is_jailed(@{{eve}}), 7357003);


      let jail_sort = Jail::sort_by_jail(*&sorted_val_universe);
      print(&jail_sort);
      print(&@{{eve}});

      let (_is_found, idx) = Vector::index_of(&jail_sort, &@{{eve}});
      print(&idx);
      assert(idx == 6, 735705);

      // jail alice 2x and she will fall to bottom of list
      Jail::jail(&vm, @{{alice}});
      Jail::jail(&vm, @{{alice}});

      let jail_sort = Jail::sort_by_jail(*&sorted_val_universe);
      let (_is_found, idx) = Vector::index_of(&jail_sort, &@{{eve}});
      print(&idx);
      assert(idx == 5, 735705);
      let (_is_found, idx) = Vector::index_of(&jail_sort, &@{{alice}});
      print(&idx);
      assert(idx == 6, 735705);

      Jail::remove_consecutive_fail(&vm, @{{eve}});
      Jail::remove_consecutive_fail(&vm, @{{alice}});

      let jail_sort = Jail::sort_by_jail(*&sorted_val_universe);
      let (_is_found, idx) = Vector::index_of(&jail_sort, &@{{eve}});
      print(&idx);
      assert(idx == 4, 735705);
    }
}
//check: EXECUTED

