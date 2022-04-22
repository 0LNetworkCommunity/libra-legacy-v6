// This tests consensus Case 3.
// DAVE is a validator.
// DID NOT validate successfully.
// DID mine above the threshold for the epoch. 

// Todo: These GAS values have no effect, all accounts start with 1M GAS
//# init --validators Alice
//! account: bob, 1000000GAS, 0, validator
//! account: carol, 1000000GAS, 0, validator
//! account: dave, 1000000GAS, 0, validator
//! account: eve, 1000000GAS, 0, validator
//! account: frank, 1000000GAS, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;

    fun main(sender: signer) {
        // tranfer enough coins to operators
        let oper_bob = ValidatorConfig::get_operator(@Bob);
        let oper_eve = ValidatorConfig::get_operator(@Eve);
        let oper_dave = ValidatorConfig::get_operator(@Dave);
        let oper_alice = ValidatorConfig::get_operator(@Alice);
        let oper_carol = ValidatorConfig::get_operator(@Carol);
        let oper_frank = ValidatorConfig::get_operator(@Frank);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Bob, oper_bob, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Eve, oper_eve, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Dave, oper_dave, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, oper_alice, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Carol, oper_carol, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@Frank, oper_frank, 50009, x"", x"", &sender);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Bob is the only one that can update her mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Bob) == 5, 7357300101011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: carol
script {    
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
        
        // Carol is the only one that can update her mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Carol) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: dave
script {
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
    }
}
//check: EXECUTED

////////////////
// SKIP DAVE MINING ///
////////////////

//! new-transaction
//! sender: eve
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Eve is the only one that can update her mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Eve) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: frank
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Frank is the only one that can update her mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Frank) == 5, 7357300101011000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    
    use DiemFramework::DiemSystem;
    use DiemFramework::TowerState;
    use DiemFramework::NodeWeight;
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    // use DiemFramework::FullnodeState;


    fun main(_vm: signer) {
        // This is not an onboarding case, steady state.
        // FullnodeState::test_set_fullnode_fixtures(
        //     &vm, @Dave, 0, 0, 0, 200, 200, 1000000
        // );

        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 6, 7357000180101);
        assert!(DiemSystem::is_validator(@Dave) == true, 7357000180102);
        assert!(TowerState::test_helper_get_height(@Dave) == 0, 7357000180104);
        assert!(DiemAccount::balance<GAS>(@Dave) == 949991, 7357000180106);
        assert!(NodeWeight::proof_of_weight(@Dave) == 0, 7357000180107);  
        assert!(TowerState::test_helper_get_height(@Dave) == 0, 7357000180108);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use Std::Vector;
    use DiemFramework::Stats;
    // use DiemFramework::FullnodeState;
    // This is the the epoch boundary.
    fun main(vm: signer) {
                // This is not an onboarding case, steady state.
        // FullnodeState::test_set_fullnode_fixtures(
        //     &vm, @Dave, 0, 0, 0, 200, 200, 1000000
        // );
        let voters = Vector::empty<address>();
        // Case 3 skip Carol, did not validate.
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        // Case 4 SKIP DAVE, did not validate
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

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Cases;

    fun main(vm: signer) {
        // We are in a new epoch.
        // Check carol is in the the correct case during reconfigure
        assert!(Cases::get_case(&vm, @Dave, 0, 15) == 4, 7357000180109);
    }
}

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
    use DiemFramework::DiemSystem;
    use DiemFramework::NodeWeight;
    use DiemFramework::GAS::GAS;
    use DiemFramework::DiemAccount;
    use DiemFramework::DiemConfig;
    use DiemFramework::Debug::print;

    fun main(_account: signer) {
        // We are in a new epoch.

        // Check the validator set is at expected size

        print(&7357666);
        print(&DiemSystem::validator_set_size());
        
        assert!(DiemSystem::validator_set_size() == 5, 7357000180110);
        assert!(DiemSystem::is_validator(@Dave) == false, 7357000180111);            
        assert!(DiemAccount::balance<GAS>(@Dave) == 949991, 7357000180112);
        assert!(NodeWeight::proof_of_weight(@Dave) == 0, 7357000180113);  
        assert!(DiemConfig::get_current_epoch()==2, 7357000180114);

    }
}
//check: EXECUTED