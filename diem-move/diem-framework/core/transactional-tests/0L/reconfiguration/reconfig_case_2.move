//# init --validators Alice Bob Carol Dave Eve Frank

// Testing if FRANK a CASE 2 Validator gets dropped.

// ALICE is CASE 1
// BOB is CASE 1
// CAROL is CASE 1
// DAVE is CASE 1
// EVE is CASE 1
// FRANK is CASE 2

//# block --proposer Alice --time 1 --round 0

//! NewBlockEvent

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::ValidatorConfig;

    fun main(dr: signer, _: signer) {
        // Transfer enough coins to operators
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

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008007001);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008007002);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008007003);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008007004);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot Eve
script {
    use DiemFramework::TowerState;
    use DiemFramework::AutoPay;

    fun main(_dr: signer, sender: signer) {
        AutoPay::enable_autopay(&sender);

        // Miner is the only one that can update their mining stats. 
        // Hence this first transaction.
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::test_helper_get_count(&sender) == 5, 7357008007005);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Stats;
    use Std::Vector;
    use DiemFramework::DiemSystem;

    fun main(vm: signer, _: signer) {
        let voters = Vector::singleton<address>(@Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        Vector::push_back<address>(&mut voters, @Eve);
        Vector::push_back<address>(&mut voters, @Frank);

        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };

        assert!(DiemSystem::validator_set_size() == 6, 7357008007006);
        assert!(DiemSystem::is_validator(@Alice) == true, 7357008007007);
    }
}
//check: EXECUTED

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

    fun main() {
        // We are in a new epoch.
        assert!(DiemConfig::get_current_epoch() == 2, 7357008007008);
        // Tests on initial size of validators 
        assert!(DiemSystem::validator_set_size() == 5, 7357008007009);
        assert!(DiemSystem::is_validator(@Frank) == false, 7357008007010);
    }
}
//check: EXECUTED