//! account: alice, 1000000GAS, 0, validator

// Create three end user miner accounts
//! account: bob, 1000000GAS, 0
//! account: carol, 1000000GAS, 0
//! account: dave, 1000000GAS, 0 // Dave will not mine above threshold

// Bob, Carol, Dave are end-users running the Carpe app, and submitting miner proofs.
// He is the only one in the epoch submitting proofs. He should get the entirety of the Identity Subsidy pool avaialable (one validator's worth)


//! new-transaction
//! sender: diemroot
script {
    use 0x1::Teams;

    fun main(vm: signer) {
      Teams::vm_init(&vm);
      // assert(rms == 8, 7357);
    }
}


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
    // use 0x1::Mock;
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
    }
}
//check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
    use 0x1::Teams;

    fun main(vm: signer) {
      let rms = Teams::find_rms_of_towers(&vm);
      assert(rms == 8, 735701);

      let thresh = Teams::set_threshold_as_pct_rms(&vm);
      assert(thresh == 2, 735702);
    }
}