//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::Debug::print;

    fun main(sender: signer) {
        // TowerState::init_miner_state(sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        // assert(TowerState::get_count_in_epoch(@{{alice}}) == 5, 73570001);

        // alice, a validator, has one fullnode proof from genesis
        // NOTE: this causes an off-by-one issue in counting fullnode proofs for genesis cases ONLY.
        // so we don't handle it.
        print(&TowerState::get_fullnode_proofs_in_epoch());
        assert(TowerState::get_fullnode_proofs_in_epoch() == 1, 735701);

        // No fullnodes submitted proofs above threshold
        print(&TowerState::get_fullnode_proofs_in_epoch_above_thresh());
        assert(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 735702);

        // Total count of proofs will be 1 from genesis + 5 mocked

        print(&TowerState::get_count_in_epoch(@{{alice}}));
        assert(TowerState::get_count_in_epoch(@{{alice}}) == 6, 735703);

        print(&TowerState::get_count_above_thresh_in_epoch(@{{alice}}));
        assert(TowerState::get_count_above_thresh_in_epoch(@{{alice}}) == 4, 735703);


    }
}
//check: EXECUTED

// //! new-transaction
// //! sender: diemroot
// script {
//     use 0x1::TowerState;
    
//     fun main(sender: signer) {
//         TowerState::test_helper_mock_reconfig(&sender, @{{alice}});
//         assert(TowerState::get_epochs_mining(@{{alice}}) == 1, 73570002);
//     }
// }
// //check: EXECUTED