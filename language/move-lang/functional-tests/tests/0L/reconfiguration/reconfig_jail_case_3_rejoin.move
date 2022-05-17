// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 1
//! account: bob, 1000000, 0, validator
// CAROL is CASE 1
//! account: carol, 1000000, 0, validator
// DAVE is CASE 1
//! account: dave, 1000000, 0, validator
// EVE is CASE 3
//! account: eve, 1000000, 0, validator
// FRANK is CASE 1
//! account: frank, 1000000, 0, validator

// GERTIE is CASE 1
//! account: gertie, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: diemroot
script {
    // use 0x1::DiemAccount;
    // use 0x1::GAS::GAS;
    use 0x1::Mock;

    fun main(vm: signer) {

        Mock::mock_case_1(&vm, @{{alice}}, 0, 15);
        Mock::mock_case_1(&vm, @{{bob}}, 0, 15);
        Mock::mock_case_1(&vm, @{{carol}}, 0, 15);
        Mock::mock_case_1(&vm, @{{dave}}, 0, 15);
        // EVE will be the case 3
        Mock::mock_case_1(&vm, @{{frank}}, 0, 15);
        Mock::mock_case_1(&vm, @{{gertie}}, 0, 15);

        
    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x1::TowerState;
    use 0x1::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update her mining stats. Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::get_count_in_epoch(@{{eve}}) == 5, 7357180102011000);
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
//! sender: diemroot
script {
    use 0x1::DiemSystem;
    use 0x1::DiemConfig;
    use 0x1::Mock;

    fun main(vm: signer) {
        // We are in a new epoch.
        assert(DiemConfig::get_current_epoch() == 2, 7357008008009);
        // Tests on initial size of validators 
        assert(DiemSystem::validator_set_size() == 6, 7357008008010);
        assert(DiemSystem::is_validator(@{{eve}}) == false, 7357008008011);


        Mock::mock_case_1(&vm, @{{alice}}, 15, 30);
        Mock::mock_case_1(&vm, @{{bob}}, 15, 30);
        Mock::mock_case_1(&vm, @{{carol}}, 15, 30);
        Mock::mock_case_1(&vm, @{{dave}}, 15, 30);
        // EVE will be the case 3
        Mock::mock_case_1(&vm, @{{frank}}, 15, 30);
        Mock::mock_case_1(&vm, @{{gertie}}, 15, 30);

    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x1::TowerState;

    fun main(sender: signer) {
        // Mock some mining so Eve can send rejoin tx
        TowerState::test_helper_mock_mining(&sender, 100);
    }
}

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
//! sender: diemroot
script {
    use 0x1::DiemSystem;
    use 0x1::DiemConfig;
    fun main(_account: signer) {
        assert(DiemConfig::get_current_epoch() == 3, 7357008008022);

        // Finally eve is a validator again
        assert(DiemSystem::is_validator(@{{eve}}), 7357008008023);
    }
}
//check: EXECUTED