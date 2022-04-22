// TODO: Not sure how this is different from increment.move test

//# init --validators Alice
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Stats;

    fun main(vm: signer){
      // Checks that stats was initialized in genesis for Alice.

      let vm = &vm;
      assert!(Stats::node_current_props(vm, @Alice) == 0, 7357190201011000);
      assert!(Stats::node_current_props(vm, @Bob) == 0, 7357190201021000);
      assert!(Stats::node_current_votes(vm, @Alice) == 0, 7357190201031000);
      assert!(Stats::node_current_votes(vm, @Bob) == 0, 7357190201014000);


      Stats::inc_prop(vm, @Alice);
      Stats::inc_prop(vm, @Alice);
      Stats::inc_prop(vm, @Bob);
      
      Stats::test_helper_inc_vote_addr(vm, @Alice);
      Stats::test_helper_inc_vote_addr(vm, @Alice);

      assert!(Stats::node_current_props(vm, @Alice) == 2, 7357190202011000);
      assert!(Stats::node_current_props(vm, @Bob) == 1, 7357190202021000);
      assert!(Stats::node_current_votes(vm, @Alice) == 2, 7357190202031000);
      assert!(Stats::node_current_votes(vm, @Bob) == 0, 7357190202041000);
    }
}
// check: EXECUTED