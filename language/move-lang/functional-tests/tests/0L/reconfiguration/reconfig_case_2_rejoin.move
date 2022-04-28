// Testing if FRANK a CASE 2 Validator gets rejoined after doing work

// ALICE is CASE 1
//! account: alice, 1000000, 0, validator
// BOB is CASE 1
//! account: bob, 1000000, 0, validator
// CAROL is CASE 1
//! account: carol, 1000000, 0, validator
// DAVE is CASE 1
//! account: dave, 1000000, 0, validator
// EVE is CASE 1
//! account: eve, 1000000, 0, validator
// FRANK is CASE 2
//! account: frank, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: diemroot
script {
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    use 0x1::ValidatorConfig;

    fun main(sender: signer) {
        // Transfer enough coins to operators
        let oper_bob = ValidatorConfig::get_operator(@{{bob}});
        let oper_eve = ValidatorConfig::get_operator(@{{eve}});
        let oper_dave = ValidatorConfig::get_operator(@{{dave}});
        let oper_alice = ValidatorConfig::get_operator(@{{alice}});
        let oper_carol = ValidatorConfig::get_operator(@{{carol}});
        let oper_frank = ValidatorConfig::get_operator(@{{frank}});
        DiemAccount::vm_make_payment_no_limit<GAS>(@{{bob}}, oper_bob, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@{{eve}}, oper_eve, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@{{dave}}, oper_dave, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@{{alice}}, oper_alice, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@{{carol}}, oper_carol, 50009, x"", x"", &sender);
        DiemAccount::vm_make_payment_no_limit<GAS>(@{{frank}}, oper_frank, 50009, x"", x"", &sender);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006002);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use 0x1::TowerState;
    use 0x1::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006003);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: dave
script {
    use 0x1::TowerState;
    use 0x1::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006004);
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

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006005);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: frank
script {
    use 0x1::AutoPay;

    fun main(sender: signer) {
        AutoPay::enable_autopay(&sender);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use 0x1::Stats;
    use 0x1::Vector;
    use 0x1::DiemSystem;

    fun main(vm: signer) {
        let voters = Vector::singleton<address>(@{{alice}});
        Vector::push_back<address>(&mut voters, @{{bob}});
        Vector::push_back<address>(&mut voters, @{{carol}});
        Vector::push_back<address>(&mut voters, @{{dave}});
        Vector::push_back<address>(&mut voters, @{{eve}});
        Vector::push_back<address>(&mut voters, @{{frank}});

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };

        assert(DiemSystem::validator_set_size() == 6, 7357008006006);
        assert(DiemSystem::is_validator(@{{alice}}) == true, 7357008006007);
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

    fun main(_account: signer) {
        // We are in a new epoch.
        assert(DiemConfig::get_current_epoch() == 2, 7357008006008);
        // Tests on initial size of validators 
        assert(DiemSystem::validator_set_size() == 5, 7357008006009);
        assert(DiemSystem::is_validator(@{{frank}}) == false, 7357008006010);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
    use 0x1::DiemSystem;
    use 0x1::DiemConfig;
    fun main(_account: signer) {
        // We are in a new epoch.
        assert(DiemConfig::get_current_epoch() == 2, 7357008006011);
        // Tests on initial size of validators 
        assert(DiemSystem::validator_set_size() == 5, 7357008006012);
        assert(DiemSystem::is_validator(@{{frank}})
         == false, 7357180105031000);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    // use 0x1::EpochBoundary;
    use 0x1::Cases;
    use 0x1::Vector;
    use 0x1::Stats;
    // use 0x1::TowerState;
    use 0x1::Debug::print;

    fun main(vm: signer) {
        let vm = &vm;
        // start a new epoch.
        // Everyone Validates. Frank later doesn't mine.
        let voters = Vector::singleton<address>(@{{alice}});
        Vector::push_back<address>(&mut voters, @{{bob}});
        Vector::push_back<address>(&mut voters, @{{carol}});
        Vector::push_back<address>(&mut voters, @{{dave}});
        Vector::push_back<address>(&mut voters, @{{eve}});
        Vector::push_back<address>(&mut voters, @{{frank}});

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };

        // Even though Eve will be considered a case 2, it was because she 
        // was jailed. She will rejoin next epoch.
        print(&777777777777777);

        // TowerState::test_helper_mock_mining_vm(vm, @{{eve}}, 5);

        print(&Cases::get_case(vm, @{{eve}}, 0, 15));
        assert(Cases::get_case(vm, @{{eve}}, 0, 15) == 2, 7357008006013);

        // EpochBoundary::reconfigure(vm, 30);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;

    fun main(sender: signer) {
        // Miner is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006014);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;

    fun main(sender: signer) {
        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006015);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use 0x1::TowerState;

    fun main(sender: signer) {
        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006016);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: dave
script {
    use 0x1::TowerState;

    fun main(sender: signer) {
        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006017);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use 0x1::TowerState;

    // use 0x1::Cases;
    // use 0x1::Debug::print;

    fun main(sender: signer) {
        // Miner is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);        
        
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006018);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: frank
script {
    use 0x1::TowerState;

    fun main(sender: signer) {
        // Miner is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert(TowerState::test_helper_get_count(&sender) == 5, 7357008006019);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: diemroot
script {

    use 0x1::Cases;

    fun main(sender: signer) {
        // Frank can rejoin as he did mining
        assert(Cases::get_case(&sender, @{{frank}}, 15, 30) == 3, 7357008006019);

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
//! sender: diemroot
script {
    use 0x1::DiemSystem;
    use 0x1::DiemConfig;
    use 0x1::Debug::print;

    fun main(_account: signer) {
        assert(DiemConfig::get_current_epoch() == 3, 7357008006020);
        print(&888888888888);

        print(&DiemSystem::validator_set_size());
        assert(DiemSystem::validator_set_size() == 6, 7357008006021);
        assert(DiemSystem::is_validator(@{{frank}}), 7357008006022);
    }
}
//check: EXECUTED
