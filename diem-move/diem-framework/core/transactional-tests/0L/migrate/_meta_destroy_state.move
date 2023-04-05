//# init --validators Alice

// 1. test that we can use the test-suite to delete a struct from vm
//    to mock the state correctly for migrations.

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;
    // use DiemFramework::Debug::print;
    fun main(vm: signer, _: signer) {
        // destroy the struct
        TowerState::test_danger_destroy_tower_counter(&vm);
        
        // should not find anything
        assert!(TowerState::test_get_liftime_proofs() > 0, 7357001);
    }
}
// check: EXECUTION_FAILURE