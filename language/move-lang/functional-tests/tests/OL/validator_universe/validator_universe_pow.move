// Updating existing validator weight info
// currently aborts because block_height is set to 0
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

//! new-transaction
//! sender: association
script{
use 0x0::ValidatorUniverse;
fun main() {
    // Borrow validator universe for modification
    ValidatorUniverse::add_validator(0xDEADBEEF);
    ValidatorUniverse::proof_of_weight(0xDEADBEEF, true);
}
}
// check: EXECUTED
