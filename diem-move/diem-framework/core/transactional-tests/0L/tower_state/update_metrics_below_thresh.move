//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    // SIMULATES A MINER ONBOARDING PROOF (proof_0.json)
    fun main(sender: signer) {
        let height_after = 0;
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
        //above test function was updated to set height to 1 for oracle E2E test, need to reset to 0 here. 
        TowerState::test_helper_set_weight(&sender, 0);

        // check for initialized TowerState
        let verified_tower_height_after = TowerState::test_helper_get_height(@Alice);

        assert!(verified_tower_height_after == height_after, 10008001);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;

    // Simulating the VM calling epoch boundary update_metrics.
    fun main(sender: signer) {
        let sender = &sender;
        //update_metrics

        assert!(TowerState::test_helper_get_height(@Alice) == 0, 10009001);
        assert!(TowerState::get_miner_latest_epoch(@Alice) == 1, 10009002);
        assert!(TowerState::get_count_in_epoch(@Alice) == 1, 10009003);
        assert!(TowerState::test_helper_get_contiguous_vm(sender, @Alice) == 0, 10009005);
        
        TowerState::test_helper_mock_reconfig(sender, @Alice);

        assert!(TowerState::test_helper_get_height(@Alice) == 0, 10009006);
        assert!(TowerState::get_miner_latest_epoch(@Alice) == 1, 10009007);
        assert!(TowerState::get_count_in_epoch(@Alice) == 0, 10009008);
        assert!(TowerState::test_helper_get_contiguous_vm(sender, @Alice) == 0, 10009010);
    }
}
// check: EXECUTED

