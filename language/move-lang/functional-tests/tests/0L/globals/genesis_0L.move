//! account: alice, 100000,0, validator

//! new-transaction
//! sender: alice
script {
use 0x1::DiemSystem;
use 0x1::Tower;

    fun main(_sender: signer) {
        assert(DiemSystem::is_validator(@{{alice}}) == true, 98);
        //alice should send a proof transaction here before Tower is invoked
        assert(Tower::test_helper_get_height(@{{alice}}) == 0u64, 73570002);
    }
}
// check: EXECUTED
