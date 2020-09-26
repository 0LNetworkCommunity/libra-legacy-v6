// This test is to check if subsidy calculations are impacted by dummy node statistics.

// NOTE: We are creating 7 validators.
//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000, 0, validator
//! account: diana, 1000000, 0, validator
//! account: ethel, 1000000, 0, validator
//! account: frank, 1000000, 0, validator
//! account: vivian, 1000000, 0, validator

//! new-transaction
//! sender: libraroot
script {
  // use 0x1::Debug;  
  use 0x1::Subsidy;
  use 0x1::Vector;
  use 0x1::Stats;

  fun main(account: &signer) {
    //example range of blocks with 4 validators
    //NOTE: no epoch reconfiguration methods are being called

    let validators = Vector::singleton<address>({{vivian}});
    Vector::push_back(&mut validators, {{alice}});
    Vector::push_back(&mut validators, {{bob}});
    Vector::push_back(&mut validators, {{charlie}});

    let len = Vector::length<address>(&validators);

    assert(len == 4, 1001);
    // Debug::print(&validators);

    // create dummy validator network Statistics
    Stats::insert_voter_list(account, 1u64, &validators);
    Stats::insert_voter_list(account, 2u64, &validators);
    Stats::insert_voter_list(account, 3u64, &validators);
    let subsidy_units = Subsidy::calculate_Subsidy(account, 1, 3);
    // Debug::print(&subsidy_units);
    assert(subsidy_units == 296, 1001);

    //example range of blocks with 7 validators
    Vector::push_back(&mut validators, {{diana}});
    Vector::push_back(&mut validators, {{ethel}});
    Vector::push_back(&mut validators, {{frank}});

    let newlen = Vector::length<address>(&validators);
    assert(newlen == 7, 1002);

    Stats::insert_voter_list(account, 4u64, &validators);
    Stats::insert_voter_list(account, 5u64, &validators);
    Stats::insert_voter_list(account, 6u64, &validators);

    let subsidy_units = Subsidy::calculate_Subsidy(account, 4, 6);
    // Debug::print(&subsidy_units);
    assert(subsidy_units == 293, 1004);
    }
}
// check: EXECUTED
