// Case 1: Validators are compliant. 
// This test is to check if validators are present after the first epoch.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail with Staging and Production Constants, only for Debug - due to epoch length.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::Stats;
    fun main(_account: &signer) {
      Transaction::assert(Stats::node_current_props({{alice}}) == 1, 0);
      Transaction::assert(Stats::node_current_props({{bob}}) == 0, 0);
      Transaction::assert(Stats::node_current_votes({{alice}}) == 0, 0);
      Transaction::assert(Stats::node_current_votes({{bob}}) == 0, 0);

    }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 2

//! block-prologue
//! proposer: bob
//! block-time: 3

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::Stats;
    fun main(_account: &signer) {
      Transaction::assert(Stats::node_current_props({{alice}}) == 2, 0);
      Transaction::assert(Stats::node_current_props({{bob}}) == 1, 0);
      Transaction::assert(Stats::node_current_votes({{alice}}) == 0, 0);
      Transaction::assert(Stats::node_current_votes({{bob}}) == 0, 0);

    }
}
// check: EXECUTED