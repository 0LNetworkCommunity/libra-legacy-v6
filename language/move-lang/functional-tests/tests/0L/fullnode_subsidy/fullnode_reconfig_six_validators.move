//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0 // BOB will be the miner
//! account: carol, 1000000GAS, 0, validator
//! account: dave, 1000000GAS, 0, validator
//! account: eve, 1000000GAS, 0, validator
//! account: frank, 1000000GAS, 0, validator
//! account: gertie, 1000000GAS, 0, validator

// WE need more than 4 miners so that the validator rewards are changed 
// This test has 6 validators and one miner (Bob);

//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

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


// 2. Make sure there are validator subsidies available.
// so we need Alice to be a Case 1 validator so that there is a subsidy to be paid to validator set.

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Mock;
    use 0x1::TowerState;

    fun main(vm: signer) {
      TowerState::test_epoch_reset_counter(&vm);
      TowerState::test_helper_mock_reconfig(&vm, @{{alice}});
      TowerState::test_helper_mock_reconfig(&vm, @{{bob}});
      TowerState::test_helper_mock_reconfig(&vm, @{{carol}});
      TowerState::test_helper_mock_reconfig(&vm, @{{dave}});
      TowerState::test_helper_mock_reconfig(&vm, @{{eve}});
      TowerState::test_helper_mock_reconfig(&vm, @{{frank}});
      TowerState::test_helper_mock_reconfig(&vm, @{{gertie}});


      Mock::mock_case_1(&vm, @{{alice}});
      Mock::mock_case_1(&vm, @{{carol}});
      Mock::mock_case_1(&vm, @{{dave}});
      Mock::mock_case_1(&vm, @{{eve}});
      Mock::mock_case_1(&vm, @{{frank}});
      Mock::mock_case_1(&vm, @{{gertie}});

      // Mock the end-users submitting proofs above threshold.
      // Add 12: make it so that +2 gets above threshold so that 10 are counted as above thresh.
      TowerState::test_helper_mock_mining_vm(&vm, @{{bob}}, 12);
    }
}
//check: EXECUTED



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
    use 0x1::GAS::GAS;
    use 0x1::DiemAccount;
    use 0x1::Subsidy;
    use 0x1::Globals;
    use 0x1::Debug::print;

    fun main(_vm: signer) {
        // We are in a new epoch.

        // we expect that Bob receives the share that one validator would get.
        let expected_subsidy_for_six = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          6, //There are 6 validators now, the subisdy will be different
          Globals::get_max_validators_per_set(),
        );

        let starting_balance = 1000000;

        print(&expected_subsidy_for_six);

        let ending_balance = starting_balance + expected_subsidy_for_six/6;

        print(&DiemAccount::balance<GAS>(@{{bob}}));
        print(&DiemAccount::balance<GAS>(@{{alice}}));

        // bob gets the entire identity pool (equivalent to one sixth of the validator subsidy)
        assert(DiemAccount::balance<GAS>(@{{bob}}) == ending_balance, 735711);

    }
}
//check: EXECUTED