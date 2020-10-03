// This test is to check if Proof of weight is intialized properly

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::NodeWeight;
    fun main(_account: &signer) {
        // Valida
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 2, 7357220101011000);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 7357220101021000);
        Transaction::assert(NodeWeight::proof_of_weight({{alice}}) == 0, 7357220101031000);
    }
}
// check: EXECUTED
