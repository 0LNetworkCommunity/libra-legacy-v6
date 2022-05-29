//# init --validators Alice Carol Dave Eve Frank Gertie
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7
//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0 // BOB will be the miner
//! account: carol, 1000000GAS, 0, validator
//! account: dave, 1000000GAS, 0, validator
//! account: eve, 1000000GAS, 0, validator
//! account: frank, 1000000GAS, 0, validator
//! account: gertie, 1000000GAS, 0, validator

// THIS VALIDATOR WILL BE A CASE 2.

// WE need more than 4 miners so that the validator rewards are changed 
// This test has 6 validators and one miner (Bob);
// ONE OF THE VALIDATORS WILL NOT BE A COMPLIANT CASE 1.

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
      // gertie will BE CASE 2
      Mock::mock_case_2(&vm, @Gertie);

      // Mock the end-users submitting proofs above threshold.
      // Add 13: make it so that +2 gets above threshold 
      // Using 11 in this case because its a factor of the resulting validator payment
      // and doesnt cause rounding issues.
      TowerState::test_helper_mock_mining_vm(&vm, @Bob, 13);
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
        let expected_subsidy_for_five = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          5, //There are 5 compliant validators now, the subisdy will be different
          Globals::get_max_validators_per_set(),
        );

        let starting_balance = 1000000;

        print(&expected_subsidy_for_five);
        
        let subsidy_per_val = expected_subsidy_for_five/5;
        print(&subsidy_per_val);

        let ending_balance = starting_balance + subsidy_per_val;

        print(&ending_balance);

        print(&DiemAccount::balance<GAS>(@Bob));
        print(&DiemAccount::balance<GAS>(@Alice));

        // bob gets the entire identity pool (equivalent to one FIFTH
        // of the validator subsidy)
        assert!(DiemAccount::balance<GAS>(@Bob) == ending_balance, 735711);

    }
}
//check: EXECUTED