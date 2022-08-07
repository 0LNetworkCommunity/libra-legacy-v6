//! account: alice, 1000000GAS, 0, validator

// Create three end user miner accounts
//! account: bob, 1000000GAS, 0
//! account: carol, 1000000GAS, 0
//! account: dave, 1000000GAS, 0 // Dave will not mine above threshold

// Bob, Carol, Dave are end-users running the Carpe app, and submitting miner proofs.
// He is the only one in the epoch submitting proofs. He should get the entirety of the Identity Subsidy pool avaialable (one validator's worth)

//  0. Initialize Bob's miner state with a first proof

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

//! new-transaction
//! sender: carol
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


//! new-transaction
//! sender: dave
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
    use 0x1::Debug::print;

    fun main(vm: signer) {
      TowerState::test_epoch_reset_counter(&vm);
      TowerState::test_helper_mock_reconfig(&vm, @{{alice}});
      TowerState::test_helper_mock_reconfig(&vm, @{{bob}});
      TowerState::test_helper_mock_reconfig(&vm, @{{carol}});
      TowerState::test_helper_mock_reconfig(&vm, @{{dave}});


      // Mock the end-users submitting proofs above threshold.
      // Add 12: make it so that +2 gets above threshold so that 10 are counted as above thresh.
      TowerState::test_helper_mock_mining_vm(&vm, @{{bob}}, 12);
      TowerState::test_helper_mock_mining_vm(&vm, @{{carol}}, 12);
      TowerState::test_helper_mock_mining_vm(&vm, @{{dave}}, 1);

      print(&TowerState::get_fullnode_proofs_in_epoch());
      print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
      print(&TowerState::get_count_in_epoch(@{{bob}}));
      print(&TowerState::get_count_above_thresh_in_epoch(@{{bob}}));

      Mock::mock_case_1(&vm, @{{alice}}, 0, 15);

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
    use 0x1::TowerState;

    fun main(_vm: signer) {
        // We are in a new epoch.
        print(&TowerState::get_fullnode_proofs_in_epoch());
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        print(&TowerState::get_count_in_epoch(@{{bob}}));
        print(&TowerState::get_count_above_thresh_in_epoch(@{{bob}}));

        // we expect that Bob receives the share that one validator would get.
        let expected_subsidy = Subsidy::subsidy_curve(
          Globals::get_subsidy_ceiling_gas(),
          1, // alice is the only validator (but below 4 the reward is the same in testnet: 296000000)
          Globals::get_max_validators_per_set(),
        );

        let starting_balance = 1000000;

        print(&expected_subsidy);
        let each = expected_subsidy/2;
        print(&each);

        let ending_balance = starting_balance + expected_subsidy/2;

        print(&DiemAccount::balance<GAS>(@{{alice}}));

        print(&DiemAccount::balance<GAS>(@{{bob}}));
        print(&DiemAccount::balance<GAS>(@{{carol}}));

        // bob and carol share half the identity subsidy
        assert(DiemAccount::balance<GAS>(@{{bob}}) == ending_balance, 735711);
        assert(DiemAccount::balance<GAS>(@{{carol}}) == ending_balance, 735712);
        // dave's balance is unchanged
        assert(DiemAccount::balance<GAS>(@{{dave}}) == starting_balance, 735713);

    }
}
//check: EXECUTED