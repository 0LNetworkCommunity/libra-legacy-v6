// This test is to check if new epoch is triggered at end of 15 blocks.
// Here EPOCH-LENGTH = 15 Blocks.


//! account: alice, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! round: 15

//! new-transaction
//! sender: alice
script {
  use 0x0::LibraBlock;
  // use 0x0::Debug;
  use 0x0::Transaction;
  fun main(_account: &signer) {
    let block_height =  LibraBlock::get_current_block_height();
    // Debug::print(&block_height);
    Transaction::assert(block_height == 0, 98);

    }
}
// check: ABORTED
