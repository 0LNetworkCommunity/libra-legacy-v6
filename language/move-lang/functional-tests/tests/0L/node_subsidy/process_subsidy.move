// This test is to check if subsidy calculations are impacted by dummy node statistics.

// NOTE: We are creating 7 validators.
//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator
//! account: frank, 1000000, 0, validator
//! account: gene, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: association
script {
  // use 0x0::Transaction;
  use 0x0::Subsidy;
  use 0x0::Vector;
  use 0x0::AltStats;

  fun main(sender: &signer) {
    // check the case of a network density of 4 active validators.

    let validators = Vector::singleton<address>({{alice}});
    Vector::push_back(&mut validators, {{bob}});
    Vector::push_back(&mut validators, {{carol}});
    Vector::push_back(&mut validators, {{dave}});

    let weights = Vector::singleton<u64>(1u64);
    Vector::push_back(weights, 1u64);
    Vector::push_back(weights, 1u64);
    Vector::push_back(weights, 1u64);
    

    // create mock validator stats for full epoch
    let i = 0;
    while (i < 16) {
      AltStats::process_set_votes(&validators);
      i = i + 1;
    };

    Subsidy::process_subsidy_alt();

    }
}
// check: EXECUTED
