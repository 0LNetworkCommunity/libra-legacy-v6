//! new-transaction
// Subsidy minting should work
//! sender: association
script {
use 0x0::Subsidy;
fun main(account: &signer) {
    Subsidy::mint_subsidy(account);
}   
}

// check: MintEvent
// check: EXECUTED

//! new-transaction
// Subsidy minting with unauthorized account should not work
script {
use 0x0::Subsidy;
fun main(account: &signer) {
    Subsidy::mint_subsidy(account);
}   
}

// check: ABORTED

//! new-transaction
// Subsidy pre-burn should work
//! sender: association
script {
use 0x0::Transaction;
use 0x0::GAS;
use 0x0::Libra;
use 0x0::Subsidy;
fun main(account: &signer) {
    Subsidy::burn_subsidy(account);
    Transaction::assert(Libra::preburn_value<GAS::T>() == 0, 8005);
}   
}

// check: PreburnEvent
// check: BurnEvent
// check: EXECUTED

// Commenting as the function is private
// //! new-transaction
// //  Adding new burn account
// //! sender: association
// script {
// use 0x0::Transaction;
// use 0x0::Subsidy;
// fun main(account: &signer) {
//     Subsidy::add_burn_account(account, 0xDEADDEAD);
//     let size = Subsidy::get_burn_accounts_size(account);
//     Transaction::assert(size == 2, 8004);
// }   
// }

// //check: EXECUTED

// Commenting as the function is private
// //! new-transaction
// //  Adding new burn account
// //! sender: association
// script {
// use 0x0::Debug;
// use 0x0::Subsidy;
// fun main() {
//     let (subsidy_units, burn_units) = Subsidy::subsidy_curve(296, 4, 300, 150);
//     Debug::print(&subsidy_units);
//     Debug::print(&burn_units);
// }   
// }

// //! new-transaction
// //  Testing calculate subsidy
// //! sender: association
// script {
// use 0x0::Debug;
// use 0x0::Subsidy;
// fun main(account: &signer) {
//     let (subsidy_units, burn_units) = Subsidy::calculate_Subsidy(account, 0, 0);
//     Debug::print(&subsidy_units);
//     Debug::print(&burn_units);
// }   
// }


    