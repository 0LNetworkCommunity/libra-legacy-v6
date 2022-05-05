//# init --validators Alice Bob Carol Dave Eve Frank

// This tests consensus Case 3.
// CAROL is a validator.
// DID NOT validate successfully.
// DID mine above the threshold for the epoch. 

//# block --proposer Carol --time 1 --round 0
// NewBlockEvent

// 1. Set up validator accounts correctly. Test harness was not giving enough 
//    gas to operator accounts. TODO: check if this is still true 20211204

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;

    fun main(dr: signer, _: signer) {       
        // tranfer enough coins to operators
        let oper_bob = ValidatorConfig::get_operator(@Bob);
        let oper_eve = ValidatorConfig::get_operator(@Eve);
        let oper_dave = ValidatorConfig::get_operator(@Dave);
        let oper_alice = ValidatorConfig::get_operator(@Alice);
        let oper_carol = ValidatorConfig::get_operator(@Carol);
        let oper_frank = ValidatorConfig::get_operator(@Frank);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Bob, oper_bob, 50009, x"", x"", &dr);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Eve, oper_eve, 50009, x"", x"", &dr);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Dave, oper_dave, 50009, x"", x"", &dr);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, oper_alice, 50009, x"", x"", &dr);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Carol, oper_carol, 50009, x"", x"", &dr);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Frank, oper_frank, 50009, x"", x"", &dr);
    }
}
//check: EXECUTED

// 2. Mock mining on all accounts.

//# run --admin-script --signers DiemRoot Alice
script {    
    use DiemFramework::TowerState;
    use Std::Signer;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(Signer::address_of(&sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
    
    use DiemFramework::TowerState;
    use Std::Signer;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(Signer::address_of(&sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {    
    use DiemFramework::TowerState;
    use Std::Signer;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(Signer::address_of(&sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Dave
script {
   
    use DiemFramework::TowerState;
    use Std::Signer;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(Signer::address_of(&sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::TowerState;
    use Std::Signer;
    use DiemFramework::AutoPay;
 
    fun main(_dr: signer,sender: signer) {
        AutoPay::enable_autopay(&sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(Signer::address_of(&sender)) == 5, 73570001);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Frank
script {
    use DiemFramework::TowerState;
    use Std::Signer;
    use DiemFramework::AutoPay;

    fun main(_dr: signer,sender: signer) {
        AutoPay::enable_autopay(&sender);
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(Signer::address_of(&sender)) == 5, 73570001);
    }
}
//check: EXECUTED

// 3. Test that Carol the Case 3, has correct fixtures

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::TowerState;
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    // use DiemFramework::FullnodeState;
    
    fun main(_dr: signer, _: signer) {
        assert!(DiemSystem::validator_set_size() == 6, 7357000180101);
        assert!(DiemSystem::is_validator(@Carol) == true, 7357000180102);
        assert!(TowerState::test_helper_get_height(@Carol) == 5, 7357000180104);
        assert!(DiemAccount::balance<GAS>(@Carol) == 9949991, 7357000180106);
    }
}
// check: EXECUTED

// 4. process consensus votes

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use Std::Vector;
    use DiemFramework::Stats;
    // use DiemFramework::FullnodeState;
    // This is the the epoch boundary.
    fun main(vm: signer, _: signer) {
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);

        // Case 3 SKIP CAROL, did not validate.

        Vector::push_back<address>(&mut voters, @Dave);
        Vector::push_back<address>(&mut voters, @Eve);
        Vector::push_back<address>(&mut voters, @Frank);

        // Overwrite the statistics to mock that all have been validating.
        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.                
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };
    }
}

// 5. Check carol would be considered a Case 3 at the end of epoch

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Cases;
    
    fun main(vm: signer, _: signer) {
        // We are in a new epoch.
        // Check carol is in the the correct case during reconfigure
        assert!(Cases::get_case(&vm, @Carol, 0, 15) == 3, 7357000180109);
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
    use DiemFramework::NodeWeight;
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    use DiemFramework::DiemConfig;
    use DiemFramework::TowerState;

    fun main(_dr: signer, _account: signer) {
        // We are in a new epoch.

        // Check the validator set is at expected size
        assert!(DiemSystem::validator_set_size() == 5, 7357000180110);
        assert!(DiemSystem::is_validator(@Carol) == false, 7357000180111);
        assert!(DiemAccount::balance<GAS>(@Carol) == 9949991, 7357000180112);
        assert!(NodeWeight::proof_of_weight(@Carol) == 5, 7357000180113);  
        assert!(DiemConfig::get_current_epoch() == 2, 7357000180114);

        // Case 3 does not increment epochs_validating and mining (while case 1 does);
        assert!(TowerState::get_epochs_compliant(@Alice) == 1, 7357000180115);
        assert!(TowerState::get_epochs_compliant(@Carol) == 0, 7357000180115);
    }
}
//check: EXECUTED