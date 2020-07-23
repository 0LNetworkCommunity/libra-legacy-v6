// This test is to check if Proof of weight is intialized properly

//! account: sha, 1000000, 0, validator
//! account: vivian, 1000000, 0, validator

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::ValidatorUniverse;
    fun main(_account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 2, 1000);
        Transaction::assert(LibraSystem::is_validator({{sha}}) == true, 98);
        Transaction::assert(ValidatorUniverse::get_validator_weight({{sha}}) == 1, 98);
    }
}
// check: EXECUTED
