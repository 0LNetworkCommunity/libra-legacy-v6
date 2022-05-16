//! account: bob, 100000, 0, validator
//! account: alice, 10000000GAS

// 1. alice is onboarded as an end-user, and submits first proof (through Carpe app for example).

// Alice Submit VDF Proof
//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;
    use DiemFramework::DiemConfig;
    use DiemFramework::Debug::print;

    // SIMULATES A MINER ONBOARDING PROOF (proof_0.json)
    fun main(sender: signer) {
      print(&DiemConfig::get_current_epoch());

        TowerState::init_miner_state(
            &sender,
            &TestFixtures::alice_0_easy_chal(),
            &TestFixtures::alice_0_easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        assert!(TowerState::test_helper_get_height(@Alice) == 0, 10008001);
        assert!(TowerState::get_epochs_compliant(@Alice) == 0, 735701);

        // the last epoch mining is this one.
        assert!(TowerState::get_miner_latest_epoch(@Alice) == DiemConfig::get_current_epoch(), 735702);
        // initialization created one proof.
        // With Lazy computation, is number will not change on the next epochboundary.
        // if will only change after the next mining proof is submitted.
        assert!(TowerState::get_count_in_epoch(@Alice) == 1, 735703);
        // the nominal count will match the expected count in epoch.
        assert!(TowerState::test_helper_get_nominal_count(@Alice) == 1, 735704);

    }
}
// check: EXECUTED

// 2. one epoch with no mining from alice. Should not change nominal count.


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: bob
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemConfig;
    use DiemFramework::TowerState;
    use DiemFramework::Debug::print;

    // SIMULATES THE SECOND PROOF OF THE MINER (proof_1.json)
    fun main(_: signer) {
      print(&DiemConfig::get_current_epoch());
      print(&TowerState::get_count_in_epoch(@Alice));
      
      // the latest epoch mining cannot be the current epoch.
      assert!(TowerState::get_miner_latest_epoch(@Alice) != DiemConfig::get_current_epoch(), 735701);
      // Lazy would mean no change from before epoch boundary in nominal count
      assert!(TowerState::test_helper_get_nominal_count(@Alice) == 1, 735703);

      // but the helpers know  the actual count in epoch is 0.
      assert!(TowerState::get_count_in_epoch(@Alice) == 0, 735703);
      

    }
}


// 3. ONCE AGAIN. Just to be sure. Add one epoch with no mining from alice. Should not change nominal count.

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: bob
//! block-time: 125000000
//! round: 30

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemConfig;
    use DiemFramework::TowerState;
    use DiemFramework::Debug::print;

    // SIMULATES THE SECOND PROOF OF THE MINER (proof_1.json)
    fun main(_: signer) {
      print(&DiemConfig::get_current_epoch());
      print(&TowerState::get_count_in_epoch(@Alice));
    
      // the latest epoch mining cannot be the current epoch.
      assert!(TowerState::get_miner_latest_epoch(@Alice) != DiemConfig::get_current_epoch(), 735704);

      // Lazy would mean no change from before epoch boundary in nominal count
      assert!(TowerState::test_helper_get_nominal_count(@Alice) == 1, 735705);

      // but the helpers know  the actual count in epoch is 0.
      assert!(TowerState::get_count_in_epoch(@Alice) == 0, 735706);
      

    }
}


// 4. Alice finally sends a new miner proof, and the nominal epochs info is reset.


//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;
    use DiemFramework::DiemConfig;
    use DiemFramework::Debug::print;

    // SIMULATES THE SECOND PROOF OF THE MINER (proof_1.json)
    fun main(sender: signer) {
      let before = TowerState::get_tower_height(@Alice);

        print(&before);
        // assert!(TowerState::test_helper_get_height(@Alice) == 0, 10008001);
        
        let proof = TowerState::create_proof_blob(
            TestFixtures::alice_1_easy_chal(),
            TestFixtures::alice_1_easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
        TowerState::commit_state(&sender, proof);

        let after = TowerState::get_tower_height(@Alice);

        print(&after);

      // the cumulative tower height has increased
        assert!(after > before , 735707);
      
      // HOWEVER the nominal count is just 1 (it was reset to 0 and then a new proof was added)
      
      assert!(TowerState::test_helper_get_nominal_count(@Alice) == 1, 735708);

      // Now everthing should match as expected

      // the latest epoch mining is the current epoch.
      assert!(TowerState::get_miner_latest_epoch(@Alice) == DiemConfig::get_current_epoch(), 735709);

      // Lazy would mean no change from before epoch boundary in nominal count
      assert!(TowerState::test_helper_get_nominal_count(@Alice) == TowerState::get_count_in_epoch(@Alice), 735710);

    }
}
// check: EXECUTED


