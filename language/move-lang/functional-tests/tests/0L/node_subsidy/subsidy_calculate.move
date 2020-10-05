// This test is to check if subsidy calculations are impacted by dummy node statistics.

// NOTE: We are creating 7 validators.
//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000, 0, validator
//! account: diana, 1000000, 0, validator
//! account: ethel, 1000000, 0, validator
//! account: frank, 1000000, 0, validator
//! account: vivian, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: association
script {
  // use 0x0::Debug;
  use 0x0::Transaction;
  use 0x0::Subsidy;
  use 0x0::Vector;
  use 0x0::AltStats;

  fun main(sender: &signer) {
    //example range of blocks with 4 validators
    //NOTE: no epoch reconfiguration methods are being called

    let validators = Vector::singleton<address>({{vivian}});
    Vector::push_back(&mut validators, {{alice}});
    Vector::push_back(&mut validators, {{bob}});
    Vector::push_back(&mut validators, {{charlie}});

    let len = Vector::length<address>(&validators);

    Transaction::assert(len == 4, 1001);
    // Debug::print(&validators);

    // create dummy validator network Statistics
    AltStats::process_set_votes(&validators);
    AltStats::process_set_votes(&validators);
    AltStats::process_set_votes(&validators);

    let subsidy_units = Subsidy::calculate_Subsidy(sender, 1, 3);
    // Debug::print(&subsidy_units);
    Transaction::assert(subsidy_units == 296, 1001);

    //example range of blocks with 7 validators
    Vector::push_back(&mut validators, {{diana}});
    Vector::push_back(&mut validators, {{ethel}});
    Vector::push_back(&mut validators, {{frank}});

    let newlen = Vector::length<address>(&validators);
    Transaction::assert(newlen == 7, 1002);

    AltStats::process_set_votes(&validators);
    AltStats::process_set_votes(&validators);
    AltStats::process_set_votes(&validators);

    let subsidy_units = Subsidy::calculate_Subsidy(sender, 4, 6);
    // Debug::print(&subsidy_units);
    Transaction::assert(subsidy_units == 293, 1004);
    }
}
// check: EXECUTED
