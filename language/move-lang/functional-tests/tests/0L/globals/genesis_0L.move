//! account: alice, 100000,0, validator
//! new-transaction
//! sender: association
script {
use 0x0::Transaction;
use 0x0::LibraSystem;
use 0x0::MinerState;


    fun main(_sender: &signer) {
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 98);

        Transaction::assert(MinerState::test_helper_get_height({{alice}}) == 0u64, 73570002);
    }
}
// check: EXECUTED
