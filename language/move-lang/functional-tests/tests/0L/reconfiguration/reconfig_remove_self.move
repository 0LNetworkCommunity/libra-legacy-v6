// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 2
//! account: bob, 1000000, 0, validator
// CAROL is CASE 2
//! account: carol, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

// //! new-transaction
// //! sender: carol
// stdlib_script::ol_remove_self_validator_universe
// // check: "Keep(EXECUTED)"

// //! new-transaction
// //! sender: carol
// script {
//    use 0x1::ValidatorUniverse;
//    use 0x1::Signer;
//    fun remove_self(validator: &signer) {
//        let addr = Signer::address_of(validator);
//        if (ValidatorUniverse::is_in_universe(addr)) {
//            ValidatorUniverse::remove_self(validator);
//        };
//    }
// }
// //check: EXECUTED

//! new-transaction
//! sender: carol
stdlib_script::ol_remove_self_validator_universe
// check: "Keep(EXECUTED)"


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

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };
        // Carol is still a validator until the next epoch
        assert(LibraSystem::validator_set_size() == 3, 7357180103011000);
        assert(LibraSystem::is_validator({{alice}}), 7357180104011000);
        assert(LibraSystem::is_validator({{bob}}), 7357180104011000);
        assert(LibraSystem::is_validator({{carol}}), 7357180104011000);
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
        assert(LibraSystem::validator_set_size() == 2, 7357180105021000);
        // Carol is no longer a validator because she removed herself the previous epoch
        assert(LibraSystem::is_validator({{carol}}) == false, 7357180105031000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: libraroot
script {
    // use 0x1::Reconfigure;
    use 0x1::Vector;
    use 0x1::Stats;
    

    fun main(vm: &signer) {
        // start a new epoch.
        let voters = Vector::singleton<address>({{alice}});
        Vector::push_back<address>(&mut voters, {{bob}});

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };
    }
}
//check: EXECUTED

///////////////////////////////

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

        // carol is still not a validator because she has not rejoined. 
        assert(!LibraSystem::is_validator({{carol}}), 7357180107021000);



    }
}
//check: EXECUTED



//! new-transaction
//! sender: carol
script {
use 0x1::MinerState;
// use 0x1::LibraConfig;
fun main(sender: &signer) {
    // Mock some mining so carol can send rejoin tx
    MinerState::test_helper_mock_mining(sender, 100);
}
}

// Carol SENDS JOIN TX to rejoin validator set. 

//! new-transaction
//! sender: carol
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

        // Carol is a validator once more
        assert(LibraSystem::is_validator({{carol}}), 7357180108021000);
        assert(LibraSystem::validator_set_size() == 3, 7357180105021000);
    }
}
//check: EXECUTED



