// Test that both cases 3 and 4 are jailed.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0, validator
//! account: frank, 1000000, 0, validator

//! block-prologue
//! proposer: alice
//! block-time: 1
//! NewBlockEvent

//! new-transaction
//! sender: alice
script {

    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Alice mines (case 1)
        // "Sender" is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 7357008003001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use DiemFramework::TowerState;
    fun main(sender: signer) {
        // Eve mines (case 3)
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Eve) == 5, 7357008003002);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Stats;
    use Std::Vector;
    use DiemFramework::Cases;
    use DiemFramework::DiemSystem;

    fun main(vm: signer) {
        let vm = &vm;
        let voters = Vector::singleton<address>(@Alice);
        let i = 1;
        while (i < 15) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(vm, &voters);
            i = i + 1;
        };

        assert!(Cases::get_case(vm, @Alice, 0, 15) == 1, 7357008003003);
        assert!(Cases::get_case(vm, @Eve, 0, 15) == 3, 7357008003004);
        assert!(Cases::get_case(vm, @Frank, 0, 15) == 4, 7357008003005);

        let jailed = DiemSystem::get_jailed_set(vm, 0, 15);
        assert!(Vector::length<address>(&jailed) == 5, 7357008003006);
    }
}
//check: EXECUTED