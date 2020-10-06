// This tests consensus Case 3.
// CAROL is a validator.
// DID NOT validate successfully.
// DID mine above the threshold for the epoch. 

//! account: alice, 1, 0, validator
//! account: bob, 1, 0, validator
//! account: carol, 1, 0, validator
//! account: dave, 1, 0, validator
//! account: eve, 1, 0, validator

//! block-prologue
//! proposer: carol
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: carol
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::MinerState;
    // use 0x0::TestFixtures;
    use 0x0::NodeWeight;
    // use 0x0::Debug::print;
    use 0x0::GAS;
    use 0x0::LibraAccount;


    fun main(_sender: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 5, 7357000180101);
        Transaction::assert(LibraSystem::is_validator({{carol}}) == true, 7357000180102);
        Transaction::assert(LibraSystem::is_validator({{eve}}) == true, 7357000180103);

        Transaction::assert(MinerState::test_helper_get_height({{carol}}) == 0, 7357000180104);
        // Transaction::assert(MinerState::test_helper_hash({{carol}}) == TestFixtures::alice_1_easy_chal(), 7357000180105);
        
        // CAROL continues to mine after genesis.
        // This test is adapted from chained_from_genesis.move
        // let proof = MinerState::create_proof_blob(
        //     TestFixtures::alice_1_easy_chal(),
        //     100u64, // difficulty
        //     TestFixtures::alice_1_easy_sol()
        // );

        Transaction::assert(LibraAccount::balance<GAS::T>({{carol}}) == 1, 7357000180106);


        Transaction::assert(NodeWeight::proof_of_weight({{carol}}) == 0, 7357000180107);  

        // MinerState::commit_state(sender, proof);
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
        Transaction::assert(Cases::get_case({{carol}}, 15) == 4, 7357000180109);
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


//! block-prologue
//! proposer: alice
//! block-time: 16
//! NewBlockEvent

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::NodeWeight;
    use 0x0::GAS;
    use 0x0::LibraAccount;
    // use 0x0::Debug::print;

    fun main(_account: &signer) {
        // We are in a new epoch.

        // Check the validator set is at expected size
        // print(&LibraSystem::validator_set_size());
        Transaction::assert(LibraSystem::validator_set_size() == 4u64, 7357000180110);
        // print(&LibraSystem::is_validator({{carol}}));

        Transaction::assert(LibraSystem::is_validator({{carol}}) == false, 7357000180111);

        // print(&LibraAccount::balance<GAS::T>({{carol}}));
            
        Transaction::assert(LibraAccount::balance<GAS::T>({{carol}}) == 1, 7357000180112);

        // print(&NodeWeight::proof_of_weight({{carol}}));

        Transaction::assert(NodeWeight::proof_of_weight({{carol}}) == 0, 7357000180113);  
    }
}