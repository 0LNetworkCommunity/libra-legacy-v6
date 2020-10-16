//! account: alice, 100000,0, validator
//! new-transaction
//! sender: libraroot
script {
use 0x1::LibraSystem;
// use 0x0::MinerState;


    fun main(_sender: &signer) {
        assert(LibraSystem::is_validator({{alice}}) == true, 98);

        // assert(MinerState::test_helper_get_height({{alice}}) == 0u64, 73570002);
    }
}
// check: EXECUTED
