//# init --validators Alice

//# run --admin-script --signers DiemRoot Alice
script {
use DiemFramework::DiemSystem;
use DiemFramework::TowerState;

    fun main(_dr: signer, _sender: signer) {
        assert!(DiemSystem::is_validator(@Alice) == true, 98);
        //alice should send a proof transaction here before TowerState is invoked
        assert!(TowerState::test_helper_get_height(@Alice) == 0u64, 73570002);
    }
}
// check: EXECUTED
