//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    
    use 0x1::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 0);
        assert(MinerState::test_helper_get_count({{alice}}) == 0, 7357300101011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: libraroot
script {
    use 0x1::Stats;
    use 0x1::Vector;
    use 0x1::Cases;
    

    fun main(sender: &signer) {
        // todo: change name to Mock epochs
        // MinerState::test_helper_set_epochs(sender, 5);
        let voters = Vector::singleton<address>({{alice}});
        let i = 1;
        while (i < 4) {
            // Mock the validator doing work < 2/3 of blocks, and stats being updated.
            Stats::process_set_votes(sender, &voters);
            i = i + 1;
        };

        // Mock end of epoch for minerstate
        assert(Cases::get_case(sender, {{alice}}, 0, 15) == 4, 7357300103011000);
    }
}
//check: EXECUTED

