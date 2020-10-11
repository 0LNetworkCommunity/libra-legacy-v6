// Case 1: Validators are compliant. 
// This test is to check if validators are present after the first epoch.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail with Staging and Production Constants, only for Debug - due to epoch length.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Transaction;
    use 0x0::Stats;

    fun main() {
      Transaction::assert(Stats::node_current_props({{bob}}) == 0, 0);
      Transaction::assert(Stats::node_current_votes({{alice}}) == 0, 0);
      Transaction::assert(Stats::node_current_votes({{bob}}) == 0, 0);


        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});

        // Stats::process_set_votes(voters);

        // Overwrite the statistics to mock that all have been validating.
        let i = 1;
        while (i < 5) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };

      Transaction::assert(!Stats::node_above_thresh({{alice}}), 0);
      Transaction::assert(Stats::network_density() == 0, 0);

      let i = 1;
      while (i < 10) {
          // Mock the validator doing work for 15 blocks, and stats being updated.
          Stats::process_set_votes(&voters);
          i = i + 1;
      };

      Transaction::assert(Stats::node_above_thresh({{alice}}), 0);
      Transaction::assert(Stats::network_density() == 4, 0);
    }
}
// check: EXECUTED
