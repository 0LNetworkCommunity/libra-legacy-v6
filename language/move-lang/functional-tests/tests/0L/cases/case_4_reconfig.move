// This tests consensus Case 3.
// DAVE is a validator.
// DID NOT validate successfully.
// DID mine above the threshold for the epoch. 

//! account: alice, 1, 0, validator
//! account: bob, 1, 0, validator
//! account: carol, 1, 0, validator
//! account: dave, 1, 0, validator
//! account: eve, 1, 0, validator
//! account: frank, 1, 0, validator


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

////////////////
// SKIP DAVE ///
////////////////

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
//! sender: frank
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{frank}}) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::MinerState;
    use 0x0::NodeWeight;
    use 0x0::GAS;
    use 0x0::LibraAccount;


    fun main(_sender: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 6, 7357000180101);
        Transaction::assert(LibraSystem::is_validator({{dave}}) == true, 7357000180102);
        Transaction::assert(MinerState::test_helper_get_height({{dave}}) == 0, 7357000180104);
        Transaction::assert(LibraAccount::balance<GAS::T>({{dave}}) == 1, 7357000180106);
        Transaction::assert(NodeWeight::proof_of_weight({{dave}}) == 0, 7357000180107);  
        Transaction::assert(MinerState::test_helper_get_height({{dave}}) == 0, 7357000180108);
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
        Vector::push_back<address>(&mut voters, {{carol}});
        // SKIP DAVE
        // Vector::push_back<address>(&mut voters, {{dave}});
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
        Transaction::assert(Cases::get_case({{dave}}) == 4, 7357000180109);
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
    // use 0x0::Debug::print;

    fun main(_account: &signer) {
        // We are in a new epoch.

        // Check the validator set is at expected size
        // print(&LibraSystem::validator_set_size());
        Transaction::assert(LibraSystem::validator_set_size() == 5, 7357000180110);
        Transaction::assert(LibraSystem::is_validator({{dave}}) == false, 7357000180111);            
        Transaction::assert(LibraAccount::balance<GAS::T>({{dave}}) == 1, 7357000180112);
        Transaction::assert(NodeWeight::proof_of_weight({{dave}}) == 0, 7357000180113);  
        Transaction::assert(LibraConfig::get_current_epoch()==2, 7357000180114);

    }
}
//check: EXECUTED