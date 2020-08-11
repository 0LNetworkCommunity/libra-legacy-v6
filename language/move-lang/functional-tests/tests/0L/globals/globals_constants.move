//! account: alice, 100000,0, validator
//! new-transaction
//! sender: association
script {
use 0x0::Globals;
use 0x0::Debug;
use 0x0::Testnet;
use 0x0::Transaction;
use 0x0::LibraSystem;

    fun main(_sender: &signer) {
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 98);

        let len = Globals::get_epoch_length();
        Debug::print(&len);
        let set = LibraSystem::validator_set_size();
        Debug::print(&set);


        if (Testnet::is_testnet()){
            Transaction::assert(len == 15u64, 73570001);
        } else {
            Transaction::assert(len == 196992u64, 73570001);
        }
    }
}
// check: EXECUTED
