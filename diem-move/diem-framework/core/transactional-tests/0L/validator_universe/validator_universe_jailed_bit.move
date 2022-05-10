// Adding new validator epoch info
//! account: alice, 100000, 0, validator
//! account: eve, 100000

//! new-transaction
//! sender: alice
script{
use DiemFramework::ValidatorUniverse;
use Std::Signer;
fun main(eve_sig: signer) {
    // Test from genesis if not jailed and in universe
    let addr = Signer::address_of(&eve_sig);
    assert!(!ValidatorUniverse::is_jailed(addr), 73570001);
    assert!(ValidatorUniverse::is_in_universe(addr), 73570002);
}
}
// check: EXECUTED


//! new-transaction
//! sender: diemroot
script{
use DiemFramework::ValidatorUniverse;
// use Std::Signer;
fun main(vm: signer) {
    // Test from genesis if not jailed and in universe
    ValidatorUniverse::jail(&vm, @Alice);
    assert!(ValidatorUniverse::is_jailed(@Alice), 73570001);
    assert!(ValidatorUniverse::is_in_universe(@Alice), 73570002);
}
}
// check: EXECUTED