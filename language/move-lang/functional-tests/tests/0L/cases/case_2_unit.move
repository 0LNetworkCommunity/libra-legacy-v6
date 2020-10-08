//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 0);
        assert(MinerState::test_helper_get_count({{alice}}) == 0, 7357300101011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: association
script {
    use 0x0::MinerState;
    use 0x0::Stats;
    use 0x0::Vector;
    use 0x0::Cases;
    use 0x0::Transaction::assert;

    fun main(_sender: &signer) {
        // todo: change name to Mock epochs
        // MinerState::test_helper_set_epochs(sender, 5);
        let voters = Vector::singleton<address>({{alice}});
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };

        // Mock end of epoch for minerstate
        MinerState::test_helper_mock_reconfig({{alice}});
        assert(Cases::get_case({{alice}}) == 2, 7357300103011000);
    }
}
//check: EXECUTED

