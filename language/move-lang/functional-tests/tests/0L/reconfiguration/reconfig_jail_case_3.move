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
//! sender: association
script {
    use 0x0::MinerState;
    use 0x0::AltStats;
    use 0x0::Vector;
    use 0x0::Cases;
    use 0x0::Transaction::assert;

    fun main(_sender: &signer) {
        // todo: change name to Mock epochs
        // MinerState::test_helper_set_epochs(sender, 5);
        let voters = Vector::singleton<address>({{alice}});
        let i = 1;
        while (i < 10) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            AltStats::process_set_votes(&voters);
            i = i + 1;
        };

        // Mock end of epoch for minerstate
        MinerState::test_helper_mock_reconfig({{alice}});
        assert(Cases::get_case({{alice}}) == 3, 7357300103011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::Reconfigure;
    fun main(vm: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 6, 7357000180101);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == true, 7357000180102);
        Reconfigure::reconfigure(vm);
    }
}
// check: EXECUTED

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
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    fun main(_account: &signer) {
        // We are in a new epoch.
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 5, 7357180107);
        Transaction::assert(LibraSystem::is_validator({{alice}}) == false, 7357000180108);
        // Transaction::assert(LibraSystem::is_validator({{frank}}) == false, 7357000180109);        
    }
}
//check: EXECUTED