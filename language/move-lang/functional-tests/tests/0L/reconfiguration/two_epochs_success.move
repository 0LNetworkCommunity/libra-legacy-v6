// This test is to check if two epoch triggers succesfully happen.
// Here EPOCH-LENGTH = 15 Blocks.
// NOTE: This test will fail in test-net and Production, only for Debug - due to epoch length.

//! account: alice, 1000000, 0, validator
//! account: vivian, 1000000, 0, validator
//! account: shasha, 1000000, 0, validator
//! account: charles, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

//! block-prologue
//! proposer: vivian
//! block-time: 1
//! NewBlockEvent

//! block-prologue
//! proposer: vivian
//! block-time: 2

//! block-prologue
//! proposer: vivian
//! block-time: 3

//! block-prologue
//! proposer: vivian
//! block-time: 4

//! block-prologue
//! proposer: vivian
//! block-time: 5

//! block-prologue
//! proposer: vivian
//! block-time: 6

//! block-prologue
//! proposer: vivian
//! block-time: 7

//! block-prologue
//! proposer: vivian
//! block-time: 8

//! block-prologue
//! proposer: vivian
//! block-time: 9

//! block-prologue
//! proposer: vivian
//! block-time: 10

//! block-prologue
//! proposer: vivian
//! block-time: 11

//! block-prologue
//! proposer: vivian
//! block-time: 12

//! block-prologue
//! proposer: vivian
//! block-time: 13

//! block-prologue
//! proposer: vivian
//! block-time: 14

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Stats;

    fun main() {
        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, {{vivian}});
        Vector::push_back<address>(&mut validators, {{alice}});
        Vector::push_back<address>(&mut validators, {{charles}});
        Vector::push_back<address>(&mut validators, {{bob}});
        Vector::push_back<address>(&mut validators, {{shasha}});

        Stats::insert_voter_list(1, &validators);
        Stats::insert_voter_list(2, &validators);
        Stats::insert_voter_list(3, &validators);
        Stats::insert_voter_list(4, &validators);
        Stats::insert_voter_list(5, &validators);
        Stats::insert_voter_list(6, &validators);
        Stats::insert_voter_list(7, &validators);
        Stats::insert_voter_list(8, &validators);
        Stats::insert_voter_list(9, &validators);
        Stats::insert_voter_list(10, &validators);
        Stats::insert_voter_list(11, &validators);
        Stats::insert_voter_list(12, &validators);
        Stats::insert_voter_list(13, &validators);
        Stats::insert_voter_list(14, &validators);
        Stats::insert_voter_list(15, &validators);
    }
}

//! block-prologue
//! proposer: vivian
//! block-time: 15
//! round: 15

// check: NewEpochEvent

//! block-prologue
//! proposer: vivian
//! block-time: 16
//! NewBlockEvent

//! block-prologue
//! proposer: vivian
//! block-time: 17

//! block-prologue
//! proposer: vivian
//! block-time: 18

//! block-prologue
//! proposer: vivian
//! block-time: 19

//! block-prologue
//! proposer: vivian
//! block-time: 20

//! block-prologue
//! proposer: vivian
//! block-time: 21

//! block-prologue
//! proposer: vivian
//! block-time: 22

//! block-prologue
//! proposer: vivian
//! block-time: 23

//! block-prologue
//! proposer: vivian
//! block-time: 24

//! block-prologue
//! proposer: vivian
//! block-time: 25

//! block-prologue
//! proposer: vivian
//! block-time: 26

//! block-prologue
//! proposer: vivian
//! block-time: 27

//! block-prologue
//! proposer: vivian
//! block-time: 28

//! block-prologue
//! proposer: vivian
//! block-time: 29

//! new-transaction
//! sender: association
script {
    use 0x0::Vector;
    use 0x0::Stats;

    fun main() {
        let validators = Vector::empty<address>();
        Vector::push_back<address>(&mut validators, {{vivian}});
        Vector::push_back<address>(&mut validators, {{alice}});
        Vector::push_back<address>(&mut validators, {{charles}});
        Vector::push_back<address>(&mut validators, {{bob}});
        Vector::push_back<address>(&mut validators, {{shasha}});

        Stats::insert_voter_list(16, &validators);
        Stats::insert_voter_list(17, &validators);
        Stats::insert_voter_list(18, &validators);
        Stats::insert_voter_list(19, &validators);
        Stats::insert_voter_list(20, &validators);
        Stats::insert_voter_list(21, &validators);
        Stats::insert_voter_list(22, &validators);
        Stats::insert_voter_list(23, &validators);
        Stats::insert_voter_list(24, &validators);
        Stats::insert_voter_list(25, &validators);
        Stats::insert_voter_list(26, &validators);
        Stats::insert_voter_list(27, &validators);
        Stats::insert_voter_list(28, &validators);
        Stats::insert_voter_list(29, &validators);
        Stats::insert_voter_list(30, &validators);
    }
}

//! block-prologue
//! proposer: vivian
//! block-time: 30
//! round: 15

// check: NewEpochEvent
