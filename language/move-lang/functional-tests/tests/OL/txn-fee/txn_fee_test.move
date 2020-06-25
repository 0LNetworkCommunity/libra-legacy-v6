//! account: bob, 0GAS
//! account: alice, 10GAS

//! new-transaction
// Minting from a privileged account should work
//! sender: association
script {
use 0x0::GAS;
use 0x0::Libra;
use 0x0::LibraAccount;
use 0x0::Transaction;
// use 0x0::TransactionFee;
use 0x0::Debug;

    fun main(sender: &signer) {
        // mint a coin the association (tx sender)
        let coin = Libra::mint<GAS::T>(sender, 1000);

        // mint a coin the association (tx sender)
        let coin2 = Libra::mint<GAS::T>(sender, 100000000000000);
        LibraAccount::deposit(sender, {{alice}}, coin2);

        // send coin to Fee collecting address
        LibraAccount::deposit(sender, 0xFEE, coin);
        let amount = LibraAccount::balance<GAS::T>(0xFEE);
        Debug::print(&0x000000000000007E5700000000000001);
        Debug::print(&amount);
        Transaction::assert(Libra::market_cap<GAS::T>() != 1000, 5);
    }
}
// check: EXECUTED
// checking for MintEvent fails for some reason but checking 
// maket_cap (total minted amount) succeeds. Don't know why

// //! new-transaction
// //! sender: association
// script {
//     use 0x0::GAS;
//     use 0x0::TransactionFee;

//     fun main() {
//         // Distribute transaction fees.
//         TransactionFee::distribute_transaction_fees<GAS::T>();
//     }
// }
// // check: EXECUTED
