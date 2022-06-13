//# init --parent-vasps Alice Bob Carol X Dave Y Eve Z Frank W Gertie
// Alice, Carol, Dave, Eve, Frank, Gertie: validators with 10M GAS
// Bob, X, Y, Z, W:                    non-validators with  1M GAS

// WE need more than 4 miners so that the validator rewards are changed 
// This test has 6 validators and one miner (Bob);

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

// 2. Make sure there are validator subsidies available.
// so we need Alice to be a Case 1 validator so that there is a subsidy
// to be paid to validator set.

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Mock;
    use DiemFramework::TowerState;

    fun main(vm: signer, _: signer) {
      TowerState::test_epoch_reset_counter(&vm);
      TowerState::test_helper_mock_reconfig(&vm, @Alice);
      TowerState::test_helper_mock_reconfig(&vm, @Bob);
      TowerState::test_helper_mock_reconfig(&vm, @Carol);
      TowerState::test_helper_mock_reconfig(&vm, @Dave);
      TowerState::test_helper_mock_reconfig(&vm, @Eve);
      TowerState::test_helper_mock_reconfig(&vm, @Frank);
      TowerState::test_helper_mock_reconfig(&vm, @Gertie);

      Mock::mock_case_1(&vm, @Alice);
      Mock::mock_case_1(&vm, @Carol);
      Mock::mock_case_1(&vm, @Dave);
      Mock::mock_case_1(&vm, @Eve);
      Mock::mock_case_1(&vm, @Frank);
      Mock::mock_case_1(&vm, @Gertie);

      // Mock the end-users submitting proofs above threshold.
      // Add 12: make it so that +2 gets above threshold so that 10 are
      // counted as above thresh.
      TowerState::test_helper_mock_mining_vm(&vm, @Bob, 12);
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

    fun main() {
        // We are in a new epoch.

        // we expect that Bob receives the share that one validator would get.
        let expected_subsidy_for_six = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          6, //There are 6 validators now, the subisdy will be different
          Globals::get_max_validators_per_set(),
        );

        let starting_balance = 1000000;

        print(&expected_subsidy_for_six);

        let ending_balance = starting_balance + expected_subsidy_for_six / 6;

        print(&DiemAccount::balance<GAS>(@Bob));
        print(&DiemAccount::balance<GAS>(@Alice));

        // bob gets the entire identity pool (equivalent to one sixth of
        // the validator subsidy)
        assert!(DiemAccount::balance<GAS>(@Bob) == ending_balance, 735711);
    }
}
//check: EXECUTED