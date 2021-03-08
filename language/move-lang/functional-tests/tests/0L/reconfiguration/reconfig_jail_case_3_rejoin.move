// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 2
//! account: bob, 1000000, 0, validator
// CAROL is CASE 2
//! account: carol, 1000000, 0, validator
// DAVE is CASE 2
//! account: dave, 1000000, 0, validator
// EVE is CASE 3
//! account: eve, 1000000, 0, validator
// FRANK is CASE 2
//! account: frank, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: alice
script {
    use 0x1::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::get_count_in_epoch({{alice}}) == 5, 7357180101011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x1::MinerState;

    fun main(sender: &signer) {
        // Alice is the only one that can update her mining stats. Hence this first transaction.

        MinerState::test_helper_mock_mining(sender, 5);
        assert(MinerState::get_count_in_epoch({{eve}}) == 5, 7357180102011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: libraroot
script {
    // use 0x1::MinerState;
    use 0x1::Stats;
    use 0x1::Vector;
    // use 0x1::Reconfigure;
    use 0x1::LibraSystem;

    fun main(vm: &signer) {
        // todo: change name to Mock epochs
        // MinerState::test_helper_set_epochs(sender, 5);
        let voters = Vector::singleton<address>({{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});
        // Skip Eve.
        // Vector::push_back<address>(&mut voters, {{eve}});
        Vector::push_back<address>(&mut voters, {{frank}});

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };

        assert(LibraSystem::validator_set_size() == 6, 7357180103011000);
        assert(LibraSystem::is_validator({{alice}}), 7357180104011000);
    }
}
//check: EXECUTED

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: libraroot
script {
    use 0x1::LibraSystem;
    use 0x1::LibraConfig;
    fun main(_account: &signer) {
        // We are in a new epoch.
        assert(LibraConfig::get_current_epoch() == 2, 7357180105011000);
        // Tests on initial size of validators 
        assert(LibraSystem::validator_set_size() == 5, 7357180105021000);
        assert(LibraSystem::is_validator({{eve}}) == false, 7357180105031000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: libraroot
script {
    // use 0x1::Reconfigure;
    use 0x1::Cases;
    use 0x1::Vector;
    use 0x1::Stats;
    

    fun main(vm: &signer) {
        // start a new epoch.
        // Everyone except EVE validates, because she was jailed, not in validator set.
        let voters = Vector::singleton<address>({{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});
        Vector::push_back<address>(&mut voters, {{carol}});
        Vector::push_back<address>(&mut voters, {{dave}});
        // Vector::push_back<address>(&mut voters, {{eve}});
        Vector::push_back<address>(&mut voters, {{frank}});

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };

        // Even though Eve will be considered a case 2, it was because she was jailed. She will rejoin next epoch.
        assert(Cases::get_case(vm, {{eve}}, 0, 15) == 2, 7357180106011000);
        // Reconfigure::reconfigure(vm, 30);
    }
}
//check: EXECUTED

///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 122000000
//! round: 30

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: libraroot
script {
    use 0x1::LibraSystem;
    use 0x1::LibraConfig;
    fun main(_account: &signer) {
        assert(LibraConfig::get_current_epoch() == 3, 7357180107011000);

        // Cannot yet rejoin, since has not sent "join" transaction
        assert(!LibraSystem::is_validator({{eve}}), 7357180107021000);



    }
}
//check: EXECUTED



//! new-transaction
//! sender: eve
script {
use 0x1::MinerState;
// use 0x1::LibraConfig;
fun main(sender: &signer) {
    // Mock some mining so Eve can send rejoin tx
    MinerState::test_helper_mock_mining(sender, 100);
}
}

// EVE SENDS JOIN TX

//! new-transaction
//! sender: eve
stdlib_script::ol_join_validator_set
// check: "Keep(EXECUTED)"


///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 183000000
//! round: 45

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: libraroot
script {
    use 0x1::LibraSystem;
    use 0x1::LibraConfig;
    fun main(_account: &signer) {
        assert(LibraConfig::get_current_epoch() == 4, 7357180108011000);

        // Finally eve is a validator again
        assert(LibraSystem::is_validator({{eve}}), 7357180108021000);
    }
}
//check: EXECUTED