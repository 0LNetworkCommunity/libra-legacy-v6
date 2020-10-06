//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: association
script {
    use 0x0::Stats;
    use 0x0::Transaction;
    // use 0x0::Debug::print;

    fun main(){
      // Assumes accounts were initialized in genesis.

      Transaction::assert(Stats::node_current_props({{alice}}) == 0, 0);
      Transaction::assert(Stats::node_current_props({{bob}}) == 0, 0);
      Transaction::assert(Stats::node_current_votes({{alice}}) == 0, 0);
      Transaction::assert(Stats::node_current_votes({{bob}}) == 0, 0);


      Stats::inc_prop({{alice}});
      Stats::inc_prop({{alice}});

      Stats::inc_prop({{bob}});
      
      Stats::inc_vote({{alice}});
      Stats::inc_vote({{alice}});

      Transaction::assert(Stats::node_current_props({{alice}}) == 2, 0);
      Transaction::assert(Stats::node_current_props({{bob}}) == 1, 0);

      Transaction::assert(Stats::node_current_votes({{alice}}) == 2, 0);
      Transaction::assert(Stats::node_current_votes({{bob}}) == 0, 0);

    }
}
// check: EXECUTED