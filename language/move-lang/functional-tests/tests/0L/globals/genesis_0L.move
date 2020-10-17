//! account: alice, 100000,0, validator
//! new-transaction
//! sender: libraroot
script {
use 0x1::LibraSystem;
use 0x1::MinerState;
use 0x1::Debug::print;


    fun main(_sender: &signer) {
        assert(LibraSystem::is_validator({{alice}}) == true, 98);
        print(&MinerState::test_helper_get_height({{alice}}));
        assert(MinerState::test_helper_get_height({{alice}}) == 0u64, 73570002);
    }
}
// check: EXECUTED
