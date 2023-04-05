//# init --validators Alice --parent-vasps Bob
// Alice:     validators with 10M GAS

// Scenario: Bob is an end-user running the Carpe app, and submitting miner proofs.
// He is the only one in the epoch submitting proofs. He should get the entirety
// of the Identity Subsidy pool avaialable (one validator's worth)

// // Create Bob's account 

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;

    fun main(_dr: signer, sender: signer) {
        DiemAccount::create_user_account_with_coin(
            &sender,
            @Bob,
            x"2bffcbd0e9016013cb8ca78459f69d2f",
            1000000,
        );
        assert!(DiemAccount::exists_at(@Bob), 7357001);
        assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 7357002);
    }
}

// 1. Initialize Bob's miner state with a first proof

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


// Mock Bob (the end-user) submitting proofs above threshold.

//# run --admin-script --signers DiemRoot Bob
script {
    // use DiemFramework::DiemSystem;
    use DiemFramework::TowerState;
    // use DiemFramework::Debug::print;
    // use DiemFramework::GAS::GAS;
    // use DiemFramework::DiemAccount;
    // use DiemFramework::NodeWeight;

    fun main(_dr: signer, sender: signer) {
        // print(&TowerState::get_fullnode_proofs_in_epoch());
        // print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        
        // Bob has one proof from testrunner, and also bob's first proof
        // TODO: check this
        assert!(TowerState::get_fullnode_proofs_in_epoch() == 2, 735706);
        // there should be no proofs above threshold at this point.
        assert!(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 735707);

        // Bob needs to beabove threshold (two) before the subsequent proofs are counted.
        // adding 10 more here (which are all above threshold).
        
        TowerState::test_helper_mock_mining(&sender, 12);
        // print(&0777);
        // print(&TowerState::get_fullnode_proofs_in_epoch());
        // print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());

        // print(&TowerState::get_count_in_epoch(@Bob));
        // print(&TowerState::get_count_above_thresh_in_epoch(@Bob));
        
        // Since the threshold in test suite is 1 proof, all the 10 are
        // counted above threshold.
        assert!(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 11, 735708);

        // print(&DiemAccount::balance<GAS>(@Bob));
        // print(&DiemAccount::balance<GAS>(@Alice));
    }
}

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
    // use DiemFramework::Debug::print;

    fun main(_vm: signer, _: signer) {
        // We are in a new epoch.

        let expected_subsidy = 1000000;

        let bob_starting_balance = 1000000;

        let _ending_balance = bob_starting_balance + expected_subsidy;

        // TODO: check bob gets the whole subsidy
        assert!(DiemAccount::balance<GAS>(@Bob) > bob_starting_balance, 735711);  
    }
}