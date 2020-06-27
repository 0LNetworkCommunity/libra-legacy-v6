// Module to test get outgoing validator information
//! account: alice, 100000 ,0, validator
//! account: bob, 100000, 0, validator
//! account: carol, 100000, 0, validator
//! account: sha, 100000, 0, validator
//! account: ram, 100000, 0, validator

// Test to check the current validator list . Then trigger update to the list of validators, then re-run it. 
//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::Vector;
    fun main(_account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 5, 10008001);
        Transaction::assert(LibraSystem::is_validator({{sha}}) == true, 10008002);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 10008003);

        let (outgoing_validators, outgoing_validator_weights, sum_of_all_validator_weights)
            = LibraSystem::get_outgoing_validators_with_weights();
        Transaction::assert(Vector::length(&outgoing_validators) == 5, 10008004);
        Transaction::assert(Vector::length(&outgoing_validator_weights) == 5, 10008005);
        Transaction::assert(sum_of_all_validator_weights == 5, 10008006);
    }
}
// check: EXECUTED