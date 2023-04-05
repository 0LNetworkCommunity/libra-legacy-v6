//# init --validators Alice Bob Carol Dave Eve Frank Gertie

// Testing if EVE a CASE 3 Validator gets dropped.

// ALICE is CASE 1
// BOB is CASE 1
// CAROL is CASE 1
// DAVE is CASE 1
// EVE is CASE 3
// FRANK is CASE 1
// GERTIE is CASE 1

//# block --proposer Alice --time 1 --round 0

//! NewBlockEvent

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Mock;

    fun main(vm: signer, _: signer) {
        Mock::mock_case_1(&vm, @Alice, 0, 15);
        Mock::mock_case_1(&vm, @Bob, 0, 15);
        Mock::mock_case_1(&vm, @Carol, 0, 15);
        Mock::mock_case_1(&vm, @Dave, 0, 15);
        // EVE will be the case 3
        Mock::mock_case_1(&vm, @Frank, 0, 15);
        Mock::mock_case_2(&vm, @Gertie, 0, 15);
    }
}

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;
    use DiemFramework::Jail;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update her mining stats.
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Eve) == 5, 7357180102011000);

        assert!(!Jail::is_jailed(@Eve), 7357180102011001);
    }
}

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;
    use DiemFramework::Debug::print;
    use DiemFramework::Mock;

    fun main(vm: signer, _: signer) {
        // We are in a new epoch.
        assert!(DiemConfig::get_current_epoch() == 2, 7357008008009);
        // Tests on initial size of validators 
        print(&99999999999999);
        print(&DiemSystem::validator_set_size());        
        assert!(DiemSystem::validator_set_size() == 6, 7357008008010);
        assert!(DiemSystem::is_validator(@Eve) == false, 7357008008011);

        Mock::mock_case_1(&vm, @Alice, 0, 15);
        Mock::mock_case_1(&vm, @Bob, 0, 15);
        Mock::mock_case_1(&vm, @Carol, 0, 15);
        Mock::mock_case_1(&vm, @Dave, 0, 15);
        // EVE will be the case 3
        Mock::mock_case_1(&vm, @Frank, 0, 15);
        Mock::mock_case_2(&vm, @Gertie, 0, 15);        
    }
}

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::TowerState;
    use DiemFramework::Vouch;

    fun main(_dr: signer, sender: signer) {
        // Mock some mining so Eve can send rejoin tx
        TowerState::test_helper_mock_mining(&sender, 100);
        Vouch::init(&sender);
    }
}

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Vouch;
    use DiemFramework::Jail;

    fun main(_dr: signer, sender: signer) {
      Vouch::vouch_for(&sender, @Eve);
      Jail::vouch_unjail(&sender, @Eve);
    }
}

///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//# block --proposer Alice --time 122000000 --round 30

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;
    fun main() {
        assert!(DiemConfig::get_current_epoch() == 3, 7357008008022);

        // Finally eve is a validator again
        assert!(DiemSystem::is_validator(@Eve), 7357008008023);
    }
}