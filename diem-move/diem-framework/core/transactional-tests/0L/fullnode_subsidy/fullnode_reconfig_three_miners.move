//# init --validators Alice
//#      --addresses Bob=0x2e3a0b7a741dae873bf0f203a82dfd52 
//#                  Carol=0xdc79c2a4e9500e144f90e65795fc6af3
//#                  Dave=0x1ac490d22ac9007121c234b149a788ce
//#      --private-keys Bob=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8
//# Carol=23eae879e824c272c40035fd6794580e7ebff14701435ae4777f64d2412bc05c
//# Dave=0702662a6d1ccc4859ccd47663481764ec8a9452d787da2029fc20310b4f06d8


//# run --signers DiemRoot
//#     --args @Bob
//#     -- 0x1::DiemAccount::test_harness_create_user

//# run --signers DiemRoot
//#     --args @Carol
//#     -- 0x1::DiemAccount::test_harness_create_user

//# run --signers DiemRoot
//#     --args @Dave
//#     -- 0x1::DiemAccount::test_harness_create_user


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
    // use DiemFramework::Debug::print;
    
    fun main(vm: signer, _: signer) {
      TowerState::test_epoch_reset_counter(&vm);
      // TODO: Not sure these next steps are necessary
      TowerState::test_helper_mock_reconfig(&vm, @Alice);
      TowerState::test_helper_mock_reconfig(&vm, @Bob);
      TowerState::test_helper_mock_reconfig(&vm, @Carol);
      TowerState::test_helper_mock_reconfig(&vm, @Dave);

      // Mock the end-users submitting proofs above threshold.
      // Add 12: make it so that +2 gets above threshold so that 10 are
      // counted as above thresh.
      TowerState::test_helper_mock_mining_vm(&vm, @Bob, 12); // ABOVE threshold
      TowerState::test_helper_mock_mining_vm(&vm, @Carol, 12); // ABOVE threshold
      TowerState::test_helper_mock_mining_vm(&vm, @Dave, 1); // below threshold

      // print(&TowerState::get_fullnode_proofs_in_epoch());
      // print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
      // print(&TowerState::get_count_in_epoch(@Bob));
      // print(&TowerState::get_count_above_thresh_in_epoch(@Bob));


      Mock::mock_case_1(&vm, @Alice, 0, 15);

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
    // use DiemFramework::Subsidy;
    // use DiemFramework::Globals;
    // use DiemFramework::Debug::print;
    // use DiemFramework::TowerState;

    fun main(_vm: signer, _: signer) {
        // We are in a new epoch.
        // print(&TowerState::get_fullnode_proofs_in_epoch());
        // print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        // print(&TowerState::get_count_in_epoch(@Bob));
        // print(&TowerState::get_count_above_thresh_in_epoch(@Bob)); // doesn't reset until the user sends a transaction

        // we expect that Bob and Carol would split the reward that one validator would get.
        let expected_subsidy = 1000000;
        let starting_balance = 0;

        // print(&expected_subsidy);


        let _ending_balance = starting_balance + expected_subsidy / 2; // divided by 2 because we have 2 miners. Exclude Dave.

        // print(&DiemAccount::balance<GAS>(@Alice));
        // print(&DiemAccount::balance<GAS>(@Bob));
        // print(&DiemAccount::balance<GAS>(@Carol));

        // TODOL check bob and carol share half the ORACLE subsidy
        assert!(DiemAccount::balance<GAS>(@Bob) > starting_balance, 735711);

        assert!(DiemAccount::balance<GAS>(@Carol) > starting_balance, 735712);
        // dave's balance is unchanged
        assert!(DiemAccount::balance<GAS>(@Dave) == starting_balance, 735713);

    }
}
//check: EXECUTED