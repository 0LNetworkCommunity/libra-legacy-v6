//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0


// Bob is an end-user running the Carpe app, and submitting miner proofs.
// He is the only one in the epoch submitting proofs. He should get the entirety of the Identity Subsidy pool avaialable (one validator's worth)


// 1. Initialize Bob's miner state with a first proof

//! new-transaction
//! sender: bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(sender: signer) {
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
    }
}




// 1. Reset all counters and make sure there are validator subsidies available.
// We need Alice to be a Case 1 validator so that there is a subsidy to be paid to validator set.

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Mock;
    use DiemFramework::TowerState;
    use DiemFramework::DiemAccount;
    use DiemFramework::NodeWeight;
    use DiemFramework::GAS::GAS;

    fun main(vm: signer) {
      // Test suite makes all validators have 1 fullnode proof when starting.
      // need to reset to avoid confusion.
      TowerState::test_epoch_reset_counter(&vm);
      TowerState::test_helper_mock_reconfig(&vm, @Alice);
      TowerState::test_helper_mock_reconfig(&vm, @Bob);

      // make alice a compliant validator, and mine 10 proofs
      Mock::mock_case_1(&vm, @Alice);
      assert!(TowerState::get_count_in_epoch(@Alice) == 10, 735701);
      // print(&TowerState::get_count_in_epoch(@Alice));
      assert!(DiemAccount::balance<GAS>(@Alice) == 1000000, 735704);
      assert!(NodeWeight::proof_of_weight(@Alice) == 10, 735705);
    }
}
//check: EXECUTED





// 3. Mock Bob (the end-user) submitting proofs above threshold.

//! new-transaction
//! sender: bob
script {
    // use DiemFramework::DiemSystem;
    use DiemFramework::TowerState;
    use DiemFramework::Debug::print;
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    // use DiemFramework::NodeWeight;


    fun main(sender: signer) {
        print(&TowerState::get_fullnode_proofs_in_epoch());
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        

        // Bob has one proof from init above
        assert!(TowerState::get_fullnode_proofs_in_epoch() == 0, 735706);
        // there should be no proofs above threshold at this point.
        assert!(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 735707);

        // Bob needs to beabove threshold (two) before the subsequent proofs are counted.
        // adding 10 more here (which are all above threshold).
        TowerState::test_helper_mock_mining(&sender, 12);
        print(&TowerState::get_fullnode_proofs_in_epoch());
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());

        print(&TowerState::get_count_in_epoch(@Bob));
        print(&TowerState::get_count_above_thresh_in_epoch(@Bob));

        
        // Since the threshold in test suite is 1 proof, all the 10 are counted above threshold.
        assert!(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 10, 735708);

        print(&DiemAccount::balance<GAS>(@Bob));
        print(&DiemAccount::balance<GAS>(@Alice));

        
    }
}
// check: EXECUTED


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: diemroot
script {  
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    use DiemFramework::Subsidy;
    use DiemFramework::Globals;
    use DiemFramework::Debug::print;

    fun main(_vm: signer) {
        // We are in a new epoch.

        // we expect that Bob receives the share that one validator would get.
        let expected_subsidy = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          1, // alice is the only validator (but below 4 the reward is the same in testnet: 296000000)
          Globals::get_max_validators_per_set(),
        );

        let bob_starting_balance = 1000000;

        print(&expected_subsidy);

        let ending_balance = bob_starting_balance + expected_subsidy;

        print(&DiemAccount::balance<GAS>(@Bob));
        print(&DiemAccount::balance<GAS>(@Alice));

        // bob gets the whole subsidy
        assert!(DiemAccount::balance<GAS>(@Bob) == ending_balance, 735711);  
    }
}
//check: EXECUTED