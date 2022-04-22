//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    use DiemFramework::TowerState;
    // use Std::Signer;

    fun main(sender: signer) {
        // TowerState::init_miner_state(sender);
        TowerState::test_helper_mock_mining(&sender, 5);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::TowerState;
    
    fun main(sender: signer) {
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 73570001);
        TowerState::test_helper_mock_reconfig(&sender, @Alice);
        assert!(TowerState::get_epochs_mining(@Alice) == 1, 73570002);
    }
}
//check: EXECUTED