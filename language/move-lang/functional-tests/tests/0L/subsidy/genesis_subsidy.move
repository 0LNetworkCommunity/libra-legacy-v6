//! new-transaction
// Check if genesis subsidies have been distributed
//! sender: association
script {
use 0x0::Transaction;
use 0x0::LibraAccount;
use 0x0::ValidatorUniverse;
use 0x0::Vector;
use 0x0::GAS;
fun main(account: &signer) {
    let genesis_validators = ValidatorUniverse::get_eligible_validators(account);
    let i = 0;
    let len = Vector::length(&genesis_validators);
    while (i < len) {
        let node_address = *(Vector::borrow<address>(&genesis_validators, i));
        //TODO::Below assert will fail once subsidy ceiling is changed.
        Transaction::assert(LibraAccount::balance<GAS::T>(node_address) == 74, 8006);
        i = i + 1;
    };
}
}
