//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{alice}}) == 5, 7357300101011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: association
script {
    use 0x0::Stats;
    use 0x0::Vector;
    use 0x0::Cases;
    use 0x0::Transaction::assert;

    fun main(_sender: &signer) {
        let voters = Vector::singleton<address>({{alice}});
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };

        assert(Cases::get_case({{alice}}) == 1, 7357300103011000);
    }
}
//check: EXECUTED

