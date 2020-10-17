//! account: alice, 100000,0, validator
//! new-transaction
//! sender: libraroot
script {
use 0x1::LibraSystem;
// use 0x0::MinerState;
// use 0x1::Debug::print;


    fun main(_sender: &signer) {
        // print(&LibraSystem::get_validator_set());
        assert(LibraSystem::is_validator({{alice}}) == true, 98);

        // assert(MinerState::test_helper_get_height({{alice}}) == 0u64, 73570002);
    }
}
// check: EXECUTED
