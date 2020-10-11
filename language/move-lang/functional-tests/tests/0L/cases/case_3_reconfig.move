// This tests consensus Case 3.
// CAROL is a validator.
// DID NOT validate successfully.
// DID mine above the threshold for the epoch. 

//! account: alice, 1, 0, validator
//! account: bob, 1, 0, validator
//! account: carol, 1, 0, validator
//! account: dave, 1, 0, validator
//! account: eve, 1, 0, validator
//! account: frank, 1, 0, validator


//! block-prologue
//! proposer: carol
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: alice
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    use 0x0::Signer;
    // use 0x0::Debug::print;

    fun main(sender: &signer) {
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count(Signer::address_of(sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    use 0x0::Signer;
    // use 0x0::Debug::print;

    fun main(sender: &signer) {
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count(Signer::address_of(sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    use 0x0::Signer;
    // use 0x0::Debug::print;

    fun main(sender: &signer) {
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count(Signer::address_of(sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: dave
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    use 0x0::Signer;
    // use 0x0::Debug::print;

    fun main(sender: &signer) {
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count(Signer::address_of(sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    use 0x0::Signer;
    // use 0x0::Debug::print;

    fun main(sender: &signer) {
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count(Signer::address_of(sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: frank
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    use 0x0::Signer;
    // use 0x0::Debug::print;

    fun main(sender: &signer) {
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count(Signer::address_of(sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::MinerState;
    // use 0x0::TestFixtures;
    // use 0x0::NodeWeight;
    use 0x0::Debug::print;
    use 0x0::GAS;
    use 0x0::LibraAccount;


    fun main(_sender: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 6, 7357000180101);
        Transaction::assert(LibraSystem::is_validator({{carol}}) == true, 7357000180102);
        Transaction::assert(MinerState::test_helper_get_height({{carol}}) == 0, 7357000180104);
        Transaction::assert(LibraAccount::balance<GAS::T>({{carol}}) == 1, 7357000180106);
        print(&MinerState::test_helper_get_height({{carol}}));
        Transaction::assert(MinerState::test_helper_get_height({{carol}}) == 0, 7357000180108);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 2

//! block-prologue
//! proposer: alice
//! block-time: 3

//! block-prologue
//! proposer: alice
//! block-time: 4

//! block-prologue
//! proposer: alice
//! block-time: 5

//! block-prologue
//! proposer: alice
//! block-time: 6

//! block-prologue
//! proposer: alice
//! block-time: 7

//! block-prologue
//! proposer: alice
//! block-time: 8

//! block-prologue
//! proposer: alice
//! block-time: 9

//! block-prologue
//! proposer: alice
//! block-time: 10

//! block-prologue
//! proposer: alice
//! block-time: 11

//! block-prologue
//! proposer: alice
//! block-time: 12

//! block-prologue
//! proposer: alice
//! block-time: 13

//! block-prologue
//! proposer: alice
//! block-time: 14

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Stats;
    // This is the the epoch boundary.
    fun main() {
        let voters = Vector::empty<address>();
        // Case 3 skip Carol, did not validate.
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        // Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});
        Vector::push_back<address>(&mut voters, {{eve}});
        Vector::push_back<address>(&mut voters, {{frank}});


        // Overwrite the statistics to mock that all have been validating.
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
                
            Stats::process_set_votes(&voters);
            i = i + 1;
        };
    }
}

//! new-transaction
//! sender: association
script {
    use 0x0::Cases;
    // use 0x0::Debug::print;
    use 0x0::Transaction;
    fun main(_account: &signer) {
        // We are in a new epoch.
        // Check carol is in the the correct case during reconfigure
        // print(&Cases::get_case({{carol}}));
        Transaction::assert(Cases::get_case({{carol}}) == 3, 7357000180109);
    }
}

//! block-prologue
//! proposer: alice
//! block-time: 15
//! round: 15

//////////////////////////////////////////////
///// CHECKS RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::NodeWeight;
    use 0x0::GAS;
    use 0x0::LibraAccount;
    use 0x0::LibraConfig;

    fun main(_account: &signer) {
        // We are in a new epoch.

        // Check the validator set is at expected size
        Transaction::assert(LibraSystem::validator_set_size() == 5, 7357000180110);
        Transaction::assert(LibraSystem::is_validator({{carol}}) == false, 7357000180111);
        Transaction::assert(LibraAccount::balance<GAS::T>({{carol}}) == 1, 7357000180112);
        Transaction::assert(NodeWeight::proof_of_weight({{carol}}) == 1, 7357000180113);  
        Transaction::assert(LibraConfig::get_current_epoch()==2, 7357000180114);

    }
}
//check: EXECUTED