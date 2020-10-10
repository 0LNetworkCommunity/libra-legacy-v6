//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    // use 0x0::Transaction::assert;
    use 0x0::MinerState;
    // use 0x0::Signer;
    
    fun main(sender: &signer) {
        MinerState::test_helper_mock_mining(sender, 5);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    
    fun main(_sender: &signer) {

        assert(MinerState::test_helper_get_count({{alice}}) == 5, 73570001);
        MinerState::test_helper_mock_reconfig({{alice}});
        assert(MinerState::get_epochs_mining({{alice}}) == 1, 73570002);
    }
}
//check: EXECUTED
        
