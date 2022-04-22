//# init --validators Alice
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Stats;
    use Std::Vector;

    fun main(vm: signer){
      // Check that after a reconfig the counter is reset, and archived in history.
      
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


      let set = Vector::empty<address>();
      Vector::push_back<address>(&mut set, @Alice);
      Vector::push_back<address>(&mut set, @Bob);


      Stats::reconfig(vm, &set);

      assert!(Stats::node_current_props(vm, @Alice) == 0, 0);
      assert!(Stats::node_current_props(vm, @Bob) == 0, 0);
    }
}
// check: EXECUTED