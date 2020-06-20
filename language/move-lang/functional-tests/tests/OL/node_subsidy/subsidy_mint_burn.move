//! account: alice, 0GAS
//! account: preburner, 0GAS

//! new-transaction
// Subsidy minting should work
//! sender: association
script {
//use 0x0::Transaction;
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
//use 0x0::Transaction;
use 0x0::Subsidy;
fun main(account: &signer) {
    Subsidy::mint_subsidy(account);
}   
}

// check: ABORTED
    