//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#                  Carol=0x03cb4a2ce2fcfa4eadcdc08e10cee07b
//#                  Dave=0xeadf5eda5e7d5b9eea4a119df5dc9b26
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7
//#                     Carol=49fd8b5fa77fdb08ec2a8e1cab8d864ac353e4c013f191b3e6bb5e79d3e5a67d
//#                     Dave=80942c213a3ab47091dfb6979326784856f46aad26c4946aea4f9f0c5c041a79
//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1000000GAS, 0, validator
// Create three end user miner accounts
//! account: bob, 1000000GAS, 0
//! account: carol, 1000000GAS, 0
//! account: dave, 1000000GAS, 0 // Dave will not mine above threshold

// Bob, Carol, Dave are end-users running the Carpe app, and submitting miner proofs.
// He is the only one in the epoch submitting proofs. He should get the entirety
// of the Identity Subsidy pool avaialable (one validator's worth)

//  0. Initialize Bob's miner state with a first proof

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(_dr: signer, sender: signer) {
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
    }
}

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(_dr: signer, sender: signer) {
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
    }
}


//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(_dr: signer, sender: signer) {
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
    }
}


// 2. Make sure there are validator subsidies available.
// so we need Alice to be a Case 1 validator so that there is a subsidy
// to be paid to validator set.

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Mock;
    use DiemFramework::TowerState;
    use DiemFramework::Debug::print;

    fun main(vm: signer, _: signer) {
      TowerState::test_epoch_reset_counter(&vm);
      TowerState::test_helper_mock_reconfig(&vm, @Alice);
      TowerState::test_helper_mock_reconfig(&vm, @Bob);
      TowerState::test_helper_mock_reconfig(&vm, @Carol);
      TowerState::test_helper_mock_reconfig(&vm, @Dave);


      // Mock the end-users submitting proofs above threshold.
      // Add 12: make it so that +2 gets above threshold so that 10 are
      // counted as above thresh.
      TowerState::test_helper_mock_mining_vm(&vm, @Bob, 12);
      TowerState::test_helper_mock_mining_vm(&vm, @Carol, 12);
      TowerState::test_helper_mock_mining_vm(&vm, @Dave, 1);

      print(&TowerState::get_fullnode_proofs_in_epoch());
      print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
      print(&TowerState::get_count_in_epoch(@Bob));
      print(&TowerState::get_count_above_thresh_in_epoch(@Bob));

      Mock::mock_case_1(&vm, @Alice);

    }
}
//check: EXECUTED



//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {  
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    use DiemFramework::Subsidy;
    use DiemFramework::Globals;
    use DiemFramework::Debug::print;
    use DiemFramework::TowerState;

    fun main(_vm: signer, _: signer) {
        // We are in a new epoch.
        print(&TowerState::get_fullnode_proofs_in_epoch());
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        print(&TowerState::get_count_in_epoch(@Bob));
        print(&TowerState::get_count_above_thresh_in_epoch(@Bob));

        // we expect that Bob receives the share that one validator would get.
        let expected_subsidy = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          1, // alice is the only validator (but below 4 the reward is
             // the same in testnet: 296000000)
          Globals::get_max_validators_per_set(),
        );

        let starting_balance = 1000000;

        print(&expected_subsidy);
        let each = expected_subsidy/2;
        print(&each);

        let ending_balance = starting_balance + expected_subsidy/2;

        print(&DiemAccount::balance<GAS>(@Alice));

        print(&DiemAccount::balance<GAS>(@Bob));
        print(&DiemAccount::balance<GAS>(@Carol));

        // bob and carol share half the identity subsidy
        assert!(DiemAccount::balance<GAS>(@Bob) == ending_balance, 735711);
        assert!(DiemAccount::balance<GAS>(@Carol) == ending_balance, 735712);
        // dave's balance is unchanged
        assert!(DiemAccount::balance<GAS>(@Dave) == starting_balance, 735713);

    }
}
//check: EXECUTED