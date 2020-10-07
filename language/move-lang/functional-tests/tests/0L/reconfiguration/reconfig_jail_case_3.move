// Testing if FRANK a validator that is not compliant gets dropped from set.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator
//! account: frank, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

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
//! sender: bob
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{bob}}) == 5, 7357300101011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: carol
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{carol}}) == 5, 7357300101011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: dave
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{dave}}) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{eve}}) == 5, 7357300101011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: association
script {
    // use 0x0::MinerState;
    use 0x0::Stats;
    use 0x0::Vector;
    // use 0x0::Cases;
    use 0x0::Transaction::assert;
    use 0x0::Reconfigure;
    use 0x0::LibraSystem;

    fun main(vm: &signer) {
        // todo: change name to Mock epochs
        // MinerState::test_helper_set_epochs(sender, 5);
        let voters = Vector::singleton<address>({{alice}});
        Vector::push_back<address>(voters, {{bob}});
        Vector::push_back<address>(voters, {{carol}});
        Vector::push_back<address>(voters, {{dave}});
       Vector::push_back<address>(voters, {{eve}});
        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };

        assert(LibraSystem::validator_set_size() == 6, 7357000180101);
        assert(LibraSystem::is_validator({{alice}}) == true, 7357000180102);
        Reconfigure::reconfigure(vm);
        // Mock end of epoch for minerstate
        // MinerState::test_helper_mock_reconfig({{alice}});
        // assert(Cases::get_case({{alice}}) == 3, 7357300103011000);
    }
}
//check: EXECUTED

//////////////////////////////////////////////
///// CHECKS RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! block-prologue
//! proposer: alice
//! block-time: 16

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction::assert;
    use 0x0::LibraSystem;
    fun main(_account: &signer) {
        // We are in a new epoch.
        // assert(LibraConfig::get_current_epoch() == 2, 7357180107);
        // Tests on initial size of validators 
        assert(LibraSystem::validator_set_size() == 5, 7357180207);
        assert(LibraSystem::is_validator({{alice}}) == false, 7357000180108);
        // Transaction::assert(LibraSystem::is_validator({{frank}}) == false, 7357000180109);        
    }
}
//check: EXECUTED