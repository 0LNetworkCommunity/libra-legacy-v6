// This tests consensus Case D
// Dave is a validator.
// DID NOT validate successfully, 
// DID NOT mine above the threshold for the epoch. 

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: dave
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::MinerState;
    use 0x0::TestFixtures;
    use 0x0::ValidatorUniverse;
    // use 0x0::Debug::print;

    fun main(_sender: &signer) {
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 5, 7357000180101);
        Transaction::assert(LibraSystem::is_validator({{dave}}) == true, 7357000180102);
        Transaction::assert(LibraSystem::is_validator({{eve}}) == true, 7357000180103);
        Transaction::assert(MinerState::test_helper_get_height({{dave}}) == 0, 7357000180104);
        Transaction::assert(MinerState::test_helper_hash({{dave}}) == TestFixtures::alice_1_easy_chal(), 7357000180105);
        
        Transaction::assert(ValidatorUniverse::get_validator_weight({{dave}}) == 1, 7357000180106);  

        // DAVE DOES NOT MINE
        // let proof = MinerState::create_proof_blob(
        //     TestFixtures::alice_1_easy_chal(),
        //     100u64, // difficulty
        //     TestFixtures::alice_1_easy_sol()
        // );
        // MinerState::commit_state(sender, proof);
        Transaction::assert(MinerState::test_helper_get_height({{dave}}) == 1, 7357000180107);
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
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        // exclude Dave
        // Vector::push_back<address>(&mut voters, {{dave}});
        Vector::push_back<address>(&mut voters, {{eve}});

        // Overwrite the statistics to mock that all have been validating.
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::insert_voter_list(i, &voters);
            i = i + 1;
        };
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
    // use 0x0::Debug::print;
    use 0x0::ValidatorUniverse;
    fun main(_account: &signer) {
        // We are in a new epoch.
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size() == 4, 7357000180108);
        Transaction::assert(LibraSystem::is_validator({{dave}}) == false, 7357000180109);

        // TODO: this value should be == 1, since there was no mining.
        Transaction::assert(ValidatorUniverse::get_validator_weight({{dave}}) == 1, 7357000180110);  
    }
}