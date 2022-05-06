//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7

//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1, 0, validator
//! account: bob, 1, 0

// 1. test the validator count.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::Debug::print;

    fun main(_dr: signer, sender: signer) {
        // TowerState::init_miner_state(sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        // assert!(TowerState::get_count_in_epoch(@Alice) == 5, 73570001);
        // assert!(TowerState::get_epochs_compliant(@Alice) == 1, 73570002);
        print(&TowerState::get_epochs_compliant(@Alice) );

        // alice, a validator, has one fullnode proof from genesis
        // NOTE: this causes an off-by-one issue in counting fullnode proofs
        // for genesis cases ONLY. So we don't handle it.
        print(&TowerState::get_fullnode_proofs_in_epoch());
        assert!(TowerState::get_fullnode_proofs_in_epoch() == 1, 735701);

        // No fullnodes submitted proofs above threshold
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        assert!(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 735702);

        // Total count of proofs is forced with the mock_mining

        print(&TowerState::get_count_in_epoch(@Alice));
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 735703);

        print(&TowerState::get_count_above_thresh_in_epoch(@Alice));
        assert!(TowerState::get_count_above_thresh_in_epoch(@Alice) == 3, 735704);
    }
}
//check: EXECUTED

//2. reset the counts for the next test

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;
    
    fun main(dr: signer, _: signer) {
        TowerState::test_helper_mock_reconfig(&dr, @Alice);
        // assert!(TowerState::get_epochs_compliant(@Alice) == 1, 73570002);
    }
}
//check: EXECUTED


// 3. Test we are mocking the fullnode proofs correctly.

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::Debug::print;
    use DiemFramework::TestFixtures;

    fun main(_dr: signer, sender: signer) {
        // init bob an end user from carpe
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        // alice, a validator, has one fullnode proof from genesis
        // NOTE: this causes an off-by-one issue in counting fullnode 
        // proofs for genesis cases ONLY so we don't handle it.
        print(&TowerState::get_fullnode_proofs_in_epoch());
        assert!(TowerState::get_fullnode_proofs_in_epoch() == 1, 735701);

        // No fullnodes submitted proofs above threshold
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        assert!(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 735702);

        // Total count of proofs will be 1 from genesis + 5 mocked

        print(&TowerState::get_count_in_epoch(@Bob));
        assert!(TowerState::get_count_in_epoch(@Bob) == 1, 735703);

        print(&TowerState::get_count_above_thresh_in_epoch(@Bob));
        assert!(TowerState::get_count_above_thresh_in_epoch(@Bob) == 0, 735703);

        // Total count of proofs is forced with the mock_mining
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Bob) == 5, 73570001);

        print(&TowerState::get_fullnode_proofs_in_epoch());
        assert!(TowerState::get_fullnode_proofs_in_epoch() == 6, 735701);

        // No fullnodes submitted proofs above threshold (in testnet 2 proofs 
        // are necessary before the third is counted as above thresh)
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        assert!(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 4, 735702);

        // Total count of proofs is forced with the mock_mining
        print(&TowerState::get_count_in_epoch(@Bob));
        assert!(TowerState::get_count_in_epoch(@Bob) == 5, 735703);

        print(&TowerState::get_count_above_thresh_in_epoch(@Bob));
        assert!(TowerState::get_count_above_thresh_in_epoch(@Bob) == 3, 735703);
    }
}
//check: EXECUTED

