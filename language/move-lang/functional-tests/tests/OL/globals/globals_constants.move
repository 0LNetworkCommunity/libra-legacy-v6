//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! new-transaction
//! sender: association
script {
use 0x0::Globals;
use 0x0::Debug;
use 0x0::Transaction;

    fun main(_sender: &signer) {
        let len = Globals::get_epoch_length();
        Debug::print(&len);
        Transaction::assert(len == 15u64, 98);
    }
}
// check: EXECUTED
