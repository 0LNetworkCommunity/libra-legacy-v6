// Temporary tests for non-public methods written for OL.
// Not to be executed once code is merged with OLv3
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

// Updating existing validator epoch info
//! new-transaction
//! sender: association
script{
use 0x0::ValidatorUniverse;
fun main() {
    // Borrow validator universe for modification
    ValidatorUniverse::add_validator(0xDEADBEEF);
    ValidatorUniverse::update_validator_epoch_count(0xDEADBEEF);
}
}
// check: EXECUTED
