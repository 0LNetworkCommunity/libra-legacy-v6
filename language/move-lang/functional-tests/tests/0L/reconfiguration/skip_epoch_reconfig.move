// This test is to check if two epoch triggers succesfully happen.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail in test-net and Production, only for Debug - due to epoch length.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

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

    fun main() {
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});
        Vector::push_back<address>(&mut voters, {{eve}});

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

//! block-prologue
//! proposer: alice
//! block-time: 17

//! block-prologue
//! proposer: alice
//! block-time: 18

//! block-prologue
//! proposer: alice
//! block-time: 19

//! block-prologue
//! proposer: alice
//! block-time: 20

//! block-prologue
//! proposer: alice
//! block-time: 21

//! block-prologue
//! proposer: alice
//! block-time: 22

//! block-prologue
//! proposer: alice
//! block-time: 23

//! block-prologue
//! proposer: alice
//! block-time: 24

//! block-prologue
//! proposer: alice
//! block-time: 25

//! block-prologue
//! proposer: alice
//! block-time: 26

//! block-prologue
//! proposer: alice
//! block-time: 27

//! block-prologue
//! proposer: alice
//! block-time: 28

//! block-prologue
//! proposer: alice
//! block-time: 29

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Stats;
    use 0x0::LibraSystem;
    use 0x0::Debug::print;


    fun main() {
        print(&0x0);
        print(&LibraSystem::validator_set_size());

        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});
        Vector::push_back<address>(&mut voters, {{eve}});


        let i = 16;
        while (i < 31) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::insert_voter_list(i, &voters);
            print(&0x06);
            i = i + 1;
        };

        print(&0x07);

    }
}

//! block-prologue
//! proposer: alice
//! block-time: 30
//! round: 15

//! block-prologue
//! proposer: alice
//! block-time: 31
//! round: 1

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::Debug::print;
    fun main(_account: &signer) {
        // THERE WAS NO NEW EPOCH
        // Tests on initial size of validators 
        Transaction::assert(LibraSystem::validator_set_size()==5, 1);
        Transaction::assert(LibraSystem::is_validator({{alice}}), 2);
    }
}