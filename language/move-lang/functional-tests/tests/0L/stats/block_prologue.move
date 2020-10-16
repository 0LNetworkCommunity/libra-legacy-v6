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
//! sender: libraroot
script {
    use 0x1::Stats;
    fun main(vm: &signer) {
      assert(Stats::node_current_props(vm, {{alice}}) == 1, 0);
      assert(Stats::node_current_props(vm, {{bob}}) == 0, 0);
      assert(Stats::node_current_votes(vm, {{alice}}) == 0, 0);
      assert(Stats::node_current_votes(vm, {{bob}}) == 0, 0);

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
//! sender: libraroot
script {
    use 0x1::Stats;
    fun main(vm: &signer) {
      assert(Stats::node_current_props(vm, {{alice}}) == 2, 0);
      assert(Stats::node_current_props(vm, {{bob}}) == 1, 0);
      assert(Stats::node_current_votes(vm, {{alice}}) == 0, 0);
      assert(Stats::node_current_votes(vm, {{bob}}) == 0, 0);

    }
}
// check: EXECUTED