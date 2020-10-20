// Adding new validator epoch info

//! new-transaction
//! sender: libraroot
script{
use 0x1::ValidatorUniverse;
use 0x1::Vector;
use 0x1::Debug::print;

fun main(account: &signer) {
    // let validators_in_genesis = 4;
    ValidatorUniverse::add_validator(0xDEADBEEF);
    ValidatorUniverse::add_validator(0xDEADBEEF2);

    let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(account));
    print(&len);

    // assert(len == (validators_in_genesis + 1), 100001)
}
}
// check: EXECUTED