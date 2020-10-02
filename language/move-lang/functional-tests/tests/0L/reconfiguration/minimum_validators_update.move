// This test is to check if validators are present after the first epoch.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail in test-net and Production, only for Debug - due to epoch length.

//! account: alice, 1000000, 0, validator
//! account: vivian, 1000000, 0, validator
//! account: shasha, 1000000, 0, validator
//! account: charles, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    fun main(_account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 4, 1000);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 98);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: vivian
//! block-time: 2

//! block-prologue
//! proposer: vivian
//! block-time: 3

//! block-prologue
//! proposer: vivian
//! block-time: 4

//! block-prologue
//! proposer: vivian
//! block-time: 5

//! block-prologue
//! proposer: vivian
//! block-time: 6

//! block-prologue
//! proposer: vivian
//! block-time: 7

//! block-prologue
//! proposer: vivian
//! block-time: 8

//! block-prologue
//! proposer: vivian
//! block-time: 9

//! block-prologue
//! proposer: vivian
//! block-time: 10

//! block-prologue
//! proposer: vivian
//! block-time: 11

//! block-prologue
//! proposer: vivian
//! block-time: 12

//! block-prologue
//! proposer: vivian
//! block-time: 13

//! block-prologue
//! proposer: vivian
//! block-time: 14
//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    fun main(_account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 4, 979);
    }
}
//! block-prologue
//! proposer: vivian
//! block-time: 15
//! round: 15

// check: NewEpochEvent

//! block-prologue
//! proposer: vivian
//! block-time: 16
//! NewBlockEvent


//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    fun main(_account: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 4, 979);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 981);        
    }
}