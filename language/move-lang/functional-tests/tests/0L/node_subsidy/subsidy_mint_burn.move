//! new-transaction
// Subsidy minting should work
//! sender: libraroot
script {
use 0x1::Subsidy;
fun main(account: &signer) {
    Subsidy::mint_subsidy(account);
}
}

// check: MintEvent
// check: EXECUTED

//! new-transaction
// Subsidy minting with unauthorized account should not work
script {
use 0x1::Subsidy;
fun main(account: &signer) {
    Subsidy::mint_subsidy(account);
}
}

// check: ABORTED

// // TODO (nelaturuk): We don't need this test.
// //! new-transaction
// // Subsidy pre-burn should work
// //! sender: libraroot
// script {
// use 0x1::GAS::GAS;
// use 0x1::Libra;
// use 0x1::Subsidy;
// fun main(account: &signer) {
//     Subsidy::mint_subsidy(account);
//     Subsidy::burn_subsidy(account);
//     assert(Libra::preburn_value<GAS>() == 0, 8005);
// }
// }

// // check: PreburnEvent
// // check: BurnEvent
// // check: EXECUTED

//! new-transaction
// Check if genesis subsidies have been distributed
//! sender: libraroot
script {
use 0x1::LibraAccount;
use 0x1::ValidatorUniverse;
use 0x1::Vector;
use 0x1::GAS::GAS;
fun main(account: &signer) {
    let genesis_validators = ValidatorUniverse::get_eligible_validators(account);
    let i = 0;
    let len = Vector::length(&genesis_validators);
    while (i < len) {
        let node_address = *(Vector::borrow<address>(&genesis_validators, i));
        //TODO::Below assert will fail once subsidy ceiling is changed.
        assert(LibraAccount::balance<GAS>(node_address) == 74, 8006);
        i = i + 1;
    };
}
}

// Commenting as the function is private
// //! new-transaction
// //  Adding new burn account
// //! sender: libraroot
// script {
// ;
// use 0x1::Subsidy;
// fun main(account: &signer) {
//     Subsidy::add_burn_account(account, 0xDEADDEAD);
//     let size = Subsidy::get_burn_accounts_size(account);
//     assert(size == 2, 8004);
// }
// }

// //check: EXECUTED

// Commenting as the function is private
// //! new-transaction
// //  Adding new burn account
// //! sender: libraroot
// script {
// use 0x1::Debug;
// use 0x1::Subsidy;
// fun main() {
//     let (subsidy_units, burn_units) = Subsidy::subsidy_curve(296, 4, 300, 150);
//     Debug::print(&subsidy_units);
//     Debug::print(&burn_units);
// }
// }
