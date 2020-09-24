// Updating existing validator weight info
// currently aborts because block_height is set to 0
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

//! new-transaction
//! sender: libraroot
script{
use 0x1::ValidatorUniverse;
fun main(account: &signer) {
    // Borrow validator universe for modification
    ValidatorUniverse::add_validator(0xDEADBEEF);
    ValidatorUniverse::proof_of_weight(account, 0xDEADBEEF, true);
}
}
// check: EXECUTED
