//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: association
script {
    use 0x0::AltStats;
    // use 0x0::Transaction;
    use 0x0::Vector;
    // use 0x0::Debug::print;

    fun main(){
      // Checks that altstats was initialized in genesis for Alice.

      // AltStats::initialize();
      let set = Vector::singleton({{alice}});
      Vector::push_back(&mut set, {{bob}});

      AltStats::init_set(set);
      // AltStats::init_address({{alice}});
      // AltStats::init_address({{bob}});
      // Transaction::assert(AltStats::node_current_props({{alice}}) == 0, 0);
      // Transaction::assert(AltStats::node_current_props({{bob}}) == 0, 0);
      // Transaction::assert(AltStats::node_current_votes({{alice}}) == 0, 0);
      // Transaction::assert(AltStats::node_current_votes({{bob}}) == 0, 0);


      // AltStats::inc_prop({{alice}});
      // AltStats::inc_prop({{alice}});

      // AltStats::inc_prop({{bob}});
      
      // AltStats::inc_vote({{alice}});
      // AltStats::inc_vote({{alice}});

      // Transaction::assert(AltStats::node_current_props({{alice}}) == 2, 0);
      // Transaction::assert(AltStats::node_current_props({{bob}}) == 1, 0);

      // Transaction::assert(AltStats::node_current_votes({{alice}}) == 2, 0);
      // Transaction::assert(AltStats::node_current_votes({{bob}}) == 0, 0);

    }
}
// check: EXECUTED