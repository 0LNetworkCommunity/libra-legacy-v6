//! account: alice, 1, 0, validator

//! new-transaction
//! sender: alice
script {    
    use DiemFramework::TowerState;

    fun main(sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 0);
        assert!(TowerState::get_count_in_epoch(@Alice) == 0, 7357300101011000);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::Stats;
    use Std::Vector;
    use DiemFramework::Cases;

    fun main(sender: signer) {
        let voters = Vector::singleton<address>(@Alice);
        // only voted on 1 block out of 200
        Stats::process_set_votes(&sender, &voters);

        // Mock end of epoch for minerstate
        assert!(Cases::get_case(&sender, @Alice, 0, 200) == 4, 7357300103011000);
    }
}
//check: EXECUTED

