//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: association
script {
    use 0x0::Stats;
    use 0x0::Transaction::assert;
    // use 0x0::Debug::print;

    fun main(vm: &signer){
      // Checks that altstats was initialized in genesis for Alice.

      assert(Stats::node_current_props({{alice}}) == 0, 7357190201011000);
      assert(Stats::node_current_props({{bob}}) == 0, 7357190201021000);
      assert(Stats::node_current_votes({{alice}}) == 0, 7357190201031000);
      assert(Stats::node_current_votes({{bob}}) == 0, 7357190201014000);


      Stats::inc_prop({{alice}});
      Stats::inc_prop({{alice}});

      Stats::inc_prop({{bob}});
      
      Stats::test_helper_inc_vote_addr(vm, {{alice}});
      Stats::test_helper_inc_vote_addr(vm, {{alice}});

      assert(Stats::node_current_props({{alice}}) == 2, 7357190202011000);
      assert(Stats::node_current_props({{bob}}) == 1, 7357190202021000);

      assert(Stats::node_current_votes({{alice}}) == 2, 7357190202031000);
      assert(Stats::node_current_votes({{bob}}) == 0, 7357190202041000);

    }
}
// check: EXECUTED