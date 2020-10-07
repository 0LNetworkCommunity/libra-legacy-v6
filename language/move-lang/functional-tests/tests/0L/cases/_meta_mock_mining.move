//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    use 0x0::Signer;
    
    fun main(sender: &signer) {
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::get_epochs_mining(Signer::address_of(sender)) == 5, 73570001);
    }
}
//check: EXECUTED