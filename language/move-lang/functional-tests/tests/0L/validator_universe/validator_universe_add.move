// Adding new validator epoch info
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

//! new-transaction
//! sender: alice
script{
use 0x1::ValidatorUniverse;
use 0x1::Vector;
use 0x1::Debug::print;
use 0x1::Signer;

fun main(alice_sender: &signer) {
    // let validators_in_genesis = 4;
    ValidatorUniverse::add_validator(alice_sender);
    // ValidatorUniverse::add_validator(0xDEADBEEF2);
    let account = Signer::address_of(alice_sender);
    let len = Vector::length<address>(ValidatorUniverse::get_eligible_validators(account));
    print(&len);

    // assert(len == (validators_in_genesis + 1), 100001)
}
}
// check: EXECUTED