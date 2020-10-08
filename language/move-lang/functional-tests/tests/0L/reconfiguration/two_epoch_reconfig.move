// This test is to check if two epochs succesfully happen with all validators being CASE 1.


//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator
//! account: frank, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1

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
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{dave}}) == 5, 7357300101011000);
    }
}
// //check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    fun main(sender: &signer) {
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
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{frank}}) == 5, 7357300101011000);
    }
}
//check: EXECUTED

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
    use 0x0::LibraSystem;
    use 0x0::Transaction;

    fun main() {
        Transaction::assert(LibraSystem::validator_set_size() == 6, 7357180101011000);

        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});
        Vector::push_back<address>(&mut voters, {{eve}});
        Vector::push_back<address>(&mut voters, {{frank}});

        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };
    }
}
// check: EXECUTED


//! block-prologue
//! proposer: alice
//! block-time: 15

//////////////////////////////////////////////
///// CHECKS RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

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
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{dave}}) == 5, 7357300101011000);
    }
}
// //check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x0::Transaction::assert;
    use 0x0::MinerState;
    fun main(sender: &signer) {
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
        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::test_helper_get_count({{frank}}) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 16

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

    fun main() {
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, {{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});
        Vector::push_back<address>(&mut voters, {{eve}});
        Vector::push_back<address>(&mut voters, {{frank}});


        let i = 16;
        while (i < 31) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&voters);
            i = i + 1;
        };
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 30

//////////////////////////////////////////////
///// CHECKS RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! block-prologue
//! proposer: alice
//! block-time: 31

//! new-transaction
//! sender: association
script {
    use 0x0::Transaction;
    use 0x0::LibraSystem;
    use 0x0::LibraConfig;
    fun main(_account: &signer) {
        Transaction::assert(LibraSystem::validator_set_size() == 6, 7357180103011000);
        Transaction::assert(LibraConfig::get_current_epoch() == 3, 7357180103021000);
    }
}
// check: EXECUTED