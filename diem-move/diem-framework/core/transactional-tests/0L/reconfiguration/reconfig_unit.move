//# init --validators Alice
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Stats;
    use Std::Vector;
    use DiemFramework::EpochBoundary;

    fun main(vm: signer){
      let vm = &vm;
      // Check that after a reconfig the counter is reset, and archived in history.
      assert!(Stats::node_current_props(vm, @Alice) == 0, 7357008014001);
      assert!(Stats::node_current_props(vm, @Bob) == 0, 7357008014002);
      assert!(Stats::node_current_votes(vm, @Alice) == 0, 7357008014003);
      assert!(Stats::node_current_votes(vm, @Bob) == 0, 7357008014004);


      Stats::inc_prop(vm, @Alice);
      Stats::inc_prop(vm, @Alice);

      Stats::inc_prop(vm, @Bob);
      
      Stats::test_helper_inc_vote_addr(vm, @Alice);
      Stats::test_helper_inc_vote_addr(vm, @Alice);

      assert!(Stats::node_current_props(vm, @Alice) == 2, 7357008014005);
      assert!(Stats::node_current_props(vm, @Bob) == 1, 7357008014006);
      assert!(Stats::node_current_votes(vm, @Alice) == 2, 7357008014007);
      assert!(Stats::node_current_votes(vm, @Bob) == 0, 7357008014008);


      let set = Vector::empty<address>();
      Vector::push_back<address>(&mut set, @Alice);
      Vector::push_back<address>(&mut set, @Bob);


      EpochBoundary::reconfigure(vm, 15); // reconfigure at height 15

      assert!(Stats::node_current_props(vm, @Alice) == 0, 7357008014009);
      assert!(Stats::node_current_props(vm, @Bob) == 0, 7357008014010);
    }
}
// check: EXECUTED