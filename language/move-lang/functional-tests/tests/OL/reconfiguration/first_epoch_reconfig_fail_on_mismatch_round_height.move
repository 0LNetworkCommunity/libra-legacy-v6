// This test is to check if new epoch is triggered at end of 15 blocks.
// Here EPOCH-LENGTH = 15 Blocks.
// TO DO: Genesis function call to have 15 round epochs.
// NOTE: This test will fail in test-net and Production, only for Debug - due to epoch length.

//! account: alice, 1000000, 0, validator
//! account: vivian, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 1
//! round: 15

//! new-transaction
//! sender: alice
script {
  use 0x0::LibraBlock;
  // use 0x0::Debug;
  use 0x0::Transaction;
  fun main(_account: &signer) {
    let block_height =  LibraBlock::get_current_block_height(); //borrow_global<BlockMetadata>(0xA550C18);
    // Debug::print(&0x000000000013370000001);
    // Debug::print(&block_height);
    Transaction::assert(block_height == 1, 98);

    }
}
// check: ABORTED
