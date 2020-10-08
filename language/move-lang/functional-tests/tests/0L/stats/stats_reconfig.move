//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: association
script {
    use 0x0::Stats;
    use 0x0::Transaction::assert;
    use 0x0::Vector;

    // use 0x0::Debug::print;

    fun main(vm: &signer){
      // Check that after a reconfig the counter is reset, and archived in history.
      assert(Stats::node_current_props({{alice}}) == 0, 7357190201011000);
      assert(Stats::node_current_props({{bob}}) == 0, 7357190201021000);
      assert(Stats::node_current_votes({{alice}}) == 0, 7357190201031000);
      assert(Stats::node_current_votes({{bob}}) == 0, 7357190201041000);


      Stats::inc_prop({{alice}});
      Stats::inc_prop({{alice}});

      Stats::inc_prop({{bob}});
      
      Stats::test_helper_inc_vote_addr(vm, {{alice}});
      Stats::test_helper_inc_vote_addr(vm, {{alice}});

      assert(Stats::node_current_props({{alice}}) == 2, 7357190201051000);
      assert(Stats::node_current_props({{bob}}) == 1, 7357190201061000);

      assert(Stats::node_current_votes({{alice}}) == 2, 7357190201071000);
      assert(Stats::node_current_votes({{bob}}) == 0, 7357190201081000);


      let set = Vector::empty<address>();
      Vector::push_back<address>(&mut set, {{alice}});
      Vector::push_back<address>(&mut set, {{bob}});


      Stats::reconfig(&set);

      assert(Stats::node_current_props({{alice}}) == 0, 0);
      assert(Stats::node_current_props({{bob}}) == 0, 0);


    }
}
// check: EXECUTED