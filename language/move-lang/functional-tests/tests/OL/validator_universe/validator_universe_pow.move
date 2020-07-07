// Updating existing validator weight info
// currently aborts because block_height is set to 0
//! new-transaction
//! sender: association
script{
use 0x0::ValidatorUniverse;
fun main() {
    // Borrow validator universe for modification
    ValidatorUniverse::add_validator(0xDEADBEEF);
    ValidatorUniverse::proof_of_weight(0xDEADBEEF,15, 0, true);
}
}
// check: ABORTED
