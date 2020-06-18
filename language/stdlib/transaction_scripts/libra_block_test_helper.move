script {
use 0x0::Libra;
use 0x0::LibraAccount;
use 0x0::LibraBlock;
use 0x0::Debug;

//use 0x0::Transaction;

// public fun init(_account: &signer) {
//     0x0::Transaction::assert(LibraBlock::get_current_block_height() == 1, 73);
// }
/// Preburn `amount` `Token`s from `account`.
/// This will only succeed if `account` already has a published `Preburn<Token>` resource.
    fun main<Token>(account: &signer, amount: u64) {
        Libra::preburn_to<Token>(account, LibraAccount::withdraw_from(account, amount));
        let round = LibraBlock::get_current_block_height();
        Debug::print(&0x7E5700002);
        // Debug::print(&previous_block_votes);
        Debug::print(&round);
    }
}
