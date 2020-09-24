// Adding new validator epoch info

//! new-transaction
//! sender: libraroot
script{
use 0x1::ValidatorUniverse;
use 0x1::Vector;
fun main(account: &signer) {
    let validators_in_genesis = 0;
    ValidatorUniverse::add_validator(0xDEADBEEF);
    let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(account));
    assert(len == (validators_in_genesis + 1), 100001)
}
}
// check: EXECUTED
