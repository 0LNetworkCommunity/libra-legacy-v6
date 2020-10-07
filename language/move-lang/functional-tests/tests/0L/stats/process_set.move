//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: association
script {
    use 0x0::Stats;
    use 0x0::Transaction;
    use 0x0::Vector;
    // use 0x0::Debug::print;

    fun main(){
      // Checks that altstats was initialized in genesis for Alice.
      let set = Vector::singleton({{alice}});
      Vector::push_back(&mut set, {{bob}});

      Stats::process_set_votes(&set);

      Transaction::assert(Stats::node_current_props({{alice}}) == 0, 0);
      Transaction::assert(Stats::node_current_props({{bob}}) == 0, 0);
      Transaction::assert(Stats::node_current_votes({{alice}}) == 1, 0);
      Transaction::assert(Stats::node_current_votes({{bob}}) == 1, 0);
    }
}
// check: EXECUTED