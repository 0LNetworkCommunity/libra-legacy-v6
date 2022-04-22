// Adding new validator epoch info
//! account: bob, 100000 ,0, validator


//! new-transaction
//! sender: bob
script{
use DiemFramework::ValidatorUniverse;

fun main(bob: signer) {
    ValidatorUniverse::remove_self(&bob);
}
}
// check: EXECUTED


//! new-transaction
//! sender: diemroot
script{
use DiemFramework::ValidatorUniverse;
use Std::Vector;

fun main(vm: signer) {
    let len = Vector::length<address>(
        &ValidatorUniverse::get_eligible_validators(&vm)
    );
    assert!(len == 0, 73570);
}
}
// check: EXECUTED