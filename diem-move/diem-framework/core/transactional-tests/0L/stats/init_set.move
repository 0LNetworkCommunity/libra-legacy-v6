//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Stats;
    use Std::Vector;

    fun main(vm: signer){
      let vm = &vm;
      // Checks that stats was initialized in genesis for Alice.
      let set = Vector::singleton(@Alice);
      Vector::push_back(&mut set, @Bob);

      Stats::init_set(vm, &set);

      assert!(Stats::node_current_props(vm, @Alice) == 0, 0);
      assert!(Stats::node_current_props(vm, @Bob) == 0, 0);
      assert!(Stats::node_current_votes(vm, @Alice) == 0, 0);
      assert!(Stats::node_current_votes(vm, @Bob) == 0, 0);
    }
}
// check: EXECUTED