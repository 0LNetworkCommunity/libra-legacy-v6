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
    Subsidy::burn_subsidy(account, 5);
    Transaction::assert(Libra::preburn_value<GAS::T>() == 0, 8005);
}   
}

// check: PreburnEvent
// check: BurnEvent
// check: EXECUTED

//! new-transaction
//  Adding new burn account
//! sender: association
script {
use 0x0::Transaction;
use 0x0::Subsidy;
fun main(account: &signer) {
    Subsidy::add_burn_account(account, 0xDEADDEAD);
    let size = Subsidy::get_burn_accounts_size(account);
    Transaction::assert(size == 2, 8004);
}   
}

//check: EXECUTED


    