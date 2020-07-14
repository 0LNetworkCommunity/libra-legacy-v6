//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! new-transaction
//! sender: association
script {
use 0x0::Globals;
use 0x0::Debug;
// use 0x0::Transaction;

    fun main(sender: &signer) {
        Debug::print(&0x7E57);
        // initialize_block_metadata
        Globals::initialize_block_metadata(sender);
        let height = Globals::get_current_block_height();
        Debug::print(&height);

        Globals::update_global_metadata(sender);
        let heighttwo = Globals::get_current_block_height();
        Debug::print(&heighttwo);

        // let len = Globals::get_epoch_length();
        // Debug::print(&len);
        // Transaction::assert(len == 15u64, 98);
    }
}
// check: EXECUTED
