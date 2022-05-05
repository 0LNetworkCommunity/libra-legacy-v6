// This test is to check if two epochs succesfully happen with all 
// validators being CASE 1.


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
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 7357008013001);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Bob) == 5, 7357008013002);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: carol
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Carol) == 5, 7357008013003);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: dave
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Dave) == 5, 7357008013004);
    }
}
// //check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use DiemFramework::TowerState;
    fun main(sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Eve) == 5, 7357008013005);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: frank
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Frank) == 5, 7357008013006);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Vector;
    use DiemFramework::Stats;
    use DiemFramework::DiemSystem;

    fun main(vm: signer) {
        assert!(DiemSystem::validator_set_size() == 6, 7357008013007);

        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        Vector::push_back<address>(&mut voters, @Eve);
        Vector::push_back<address>(&mut voters, @Frank);

        let i = 1;
        while (i < 16) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };
    }
}
// check: EXECUTED

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
//! sender: alice
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Alice) == 5, 7357008013008);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Bob) == 5, 7357008013009);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: carol
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Carol) == 5, 7357008013010);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: dave
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Dave) == 5, 7357008013011);
    }
}
// //check: EXECUTED

//! new-transaction
//! sender: eve
script {
    use DiemFramework::TowerState;
    fun main(sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Eve) == 5, 7357008013012);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: frank
script {
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        TowerState::test_helper_mock_mining(&sender, 5);
        assert!(TowerState::get_count_in_epoch(@Frank) == 5, 7357008013013);
    }
}
//check: EXECUTED



//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Vector;
    use DiemFramework::Stats;

    fun main(vm: signer) {
        let voters = Vector::empty<address>();
        Vector::push_back<address>(&mut voters, @Alice);
        Vector::push_back<address>(&mut voters, @Bob);
        Vector::push_back<address>(&mut voters, @Carol);
        Vector::push_back<address>(&mut voters, @Dave);
        Vector::push_back<address>(&mut voters, @Eve);
        Vector::push_back<address>(&mut voters, @Frank);


        let i = 16;
        while (i < 31) {
            // Mock the validator doing work for 15 blocks, and stats being updated.
            Stats::process_set_votes(&vm, &voters);
            i = i + 1;
        };
    }
}
// check: EXECUTED

///////////////////////////////////////////////
///// Trigger reconfiguration at 4 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 122000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////



//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemSystem;
    use DiemFramework::DiemConfig;

    fun main(_account: signer) {
        assert!(DiemSystem::validator_set_size() == 6, 73570080130014);
        assert!(DiemConfig::get_current_epoch() == 3, 7357008013015);
    }
}
// check: EXECUTED