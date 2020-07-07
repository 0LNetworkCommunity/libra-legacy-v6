// Adding new validator epoch info
//! new-transaction
//! sender: association
script{
use 0x0::ValidatorUniverse;
use 0x0::Vector;
use 0x0::Transaction;
fun main(account: &signer) {

    ValidatorUniverse::add_validator(0xDEADBEEF);
}
}
// check: EXECUTED
