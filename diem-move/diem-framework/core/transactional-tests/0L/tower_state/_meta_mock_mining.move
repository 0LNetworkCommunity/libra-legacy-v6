//! account: alice, 1, 0, validator
//! account: bob, 1, 0

// 1. test the validator count.

//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::Debug::print;

    fun main(sender: signer) {
        // TowerState::init_miner_state(sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        // assert(TowerState::get_count_in_epoch(@{{alice}}) == 5, 73570001);
        // assert(TowerState::get_epochs_compliant(@{{alice}}) == 1, 73570002);
        print(&TowerState::get_epochs_compliant(@{{alice}}) );

        // alice, a validator, has one fullnode proof from genesis
        // NOTE: this causes an off-by-one issue in counting fullnode proofs for genesis cases ONLY.
        // so we don't handle it.
        print(&TowerState::get_fullnode_proofs_in_epoch());
        assert(TowerState::get_fullnode_proofs_in_epoch() == 1, 735701);

        // No fullnodes submitted proofs above threshold
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        assert(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 735702);

        // Total count of proofs is forced with the mock_mining

        print(&TowerState::get_count_in_epoch(@{{alice}}));
        assert(TowerState::get_count_in_epoch(@{{alice}}) == 5, 735703);

        print(&TowerState::get_count_above_thresh_in_epoch(@{{alice}}));
        assert(TowerState::get_count_above_thresh_in_epoch(@{{alice}}) == 3, 735704);


    }
}
//check: EXECUTED

//2. reset the counts for the next test

//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    
    fun main(sender: signer) {
        TowerState::test_helper_mock_reconfig(&sender, @{{alice}});
        // assert(TowerState::get_epochs_compliant(@{{alice}}) == 1, 73570002);
    }
}
//check: EXECUTED


// 3. Test we are mocking the fullnode proofs correctly.

//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::Debug::print;
    use 0x1::TestFixtures;

    fun main(sender: signer) {
        // init bob an end user from carpe
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        // alice, a validator, has one fullnode proof from genesis
        // NOTE: this causes an off-by-one issue in counting fullnode proofs for genesis cases ONLY so we don't handle it.
        print(&TowerState::get_fullnode_proofs_in_epoch());
        assert(TowerState::get_fullnode_proofs_in_epoch() == 1, 735701);

        // No fullnodes submitted proofs above threshold
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        assert(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 735702);

        // Total count of proofs will be 1 from genesis + 5 mocked

        print(&TowerState::get_count_in_epoch(@{{bob}}));
        assert(TowerState::get_count_in_epoch(@{{bob}}) == 1, 735703);

        print(&TowerState::get_count_above_thresh_in_epoch(@{{bob}}));
        assert(TowerState::get_count_above_thresh_in_epoch(@{{bob}}) == 0, 735703);

        // Total count of proofs is forced with the mock_mining
        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::get_count_in_epoch(@{{bob}}) == 5, 73570001);

 
        print(&TowerState::get_fullnode_proofs_in_epoch());
        assert(TowerState::get_fullnode_proofs_in_epoch() == 6, 735701);

        // No fullnodes submitted proofs above threshold (in testnet 2 proofs are necessary before the third is counted as above thresh)
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        assert(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 4, 735702);

        // Total count of proofs is forced with the mock_mining
        print(&TowerState::get_count_in_epoch(@{{bob}}));
        assert(TowerState::get_count_in_epoch(@{{bob}}) == 5, 735703);

        print(&TowerState::get_count_above_thresh_in_epoch(@{{bob}}));
        assert(TowerState::get_count_above_thresh_in_epoch(@{{bob}}) == 3, 735703);
    }
}
//check: EXECUTED

