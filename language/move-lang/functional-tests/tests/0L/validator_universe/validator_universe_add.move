// Adding new validator epoch info
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

//! new-transaction
//! sender: diemroot
script{
use 0x1::ValidatorUniverse;
use 0x1::Vector;


fun main(vm: &signer) {
    let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(vm));
    assert(len == 1, 73570);
}
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script{
use 0x1::ValidatorUniverse;

fun main(alice_sender: &signer) {
    ValidatorUniverse::add_validator(alice_sender);
}
}
// check: EXECUTED

//! new-transaction
//! sender: diemroot
script{
use 0x1::ValidatorUniverse;
use 0x1::Vector;

fun main(vm: &signer) {

    let len = Vector::length<address>(&ValidatorUniverse::get_eligible_validators(vm));
    assert(len == 2, 73570);
}
}
// check: EXECUTED