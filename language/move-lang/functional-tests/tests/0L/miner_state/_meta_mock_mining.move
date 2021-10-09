//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    use 0x1::Tower;
    // use 0x1::Signer;

    fun main(sender: signer) {
        // Tower::init_miner_state(sender);
        Tower::test_helper_mock_mining(&sender, 5);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Tower;
    
    fun main(sender: signer) {
        assert(Tower::get_count_in_epoch(@{{alice}}) == 5, 73570001);
        Tower::test_helper_mock_reconfig(&sender, @{{alice}});
        assert(Tower::get_epochs_mining(@{{alice}}) == 1, 73570002);
    }
}
//check: EXECUTED