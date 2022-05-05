//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Stats;
    // use DiemFramework::assert;

    fun main(vm: signer){
      // Assumes accounts were initialized in genesis.
    
      let vm = &vm;
      assert!(Stats::node_current_props(vm, @Alice) == 0, 7357190201011000);
      assert!(Stats::node_current_props(vm, @Bob) == 0, 7357190201021000);
      assert!(Stats::node_current_votes(vm, @Alice) == 0, 7357190201031000);
      assert!(Stats::node_current_votes(vm, @Bob) == 0, 7357190201041000);


      Stats::inc_prop(vm, @Alice);
      Stats::inc_prop(vm, @Alice);

      Stats::inc_prop(vm, @Bob);
      
      Stats::test_helper_inc_vote_addr(vm, @Alice);
      Stats::test_helper_inc_vote_addr(vm, @Alice);

      assert!(Stats::node_current_props(vm, @Alice) == 2, 7357190201051000);
      assert!(Stats::node_current_props(vm, @Bob) == 1, 7357190201061000);

      assert!(Stats::node_current_votes(vm, @Alice) == 2, 7357190201071000);
      assert!(Stats::node_current_votes(vm, @Bob) == 0, 7357190201081000);

    }
}
// check: EXECUTED