//! account: alice, 1000000, 0, validator


// 1. test that we can use the test-suite to delete a struct from vm to mock the state correctly for migrations.

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::TowerState;
    use DiemFramework::Debug::print;
    fun main(vm: signer) {

      // destroy the struct
      TowerState::test_danger_destroy_tower_counter(&vm);
      
      // should not find anything
      print(&TowerState::test_get_liftime_proofs());

    }
}
// check: EXECUTION_FAILURE
