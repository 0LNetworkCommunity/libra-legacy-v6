//# init --validators Alice

//# run --admin-script --signers DiemRoot Alice
script {    
    use DiemFramework::TowerState;

    fun main(_dr: signer, sender: signer) {
        // Alice is the only one that can update her mining stats. 
        // Hence this first transaction.

        TowerState::test_helper_mock_mining(&sender, 0);
        assert!(TowerState::get_count_in_epoch(@Alice) == 0, 7357300101011000);
    }
}
//check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Stats;
    use Std::Vector;
    use DiemFramework::Cases;

    fun main(dr: signer, _: signer) {
        let voters = Vector::singleton<address>(@Alice);
        // only voted on 1 block out of 200
        Stats::process_set_votes(&dr, &voters);

        // Mock end of epoch for minerstate
        assert!(Cases::get_case(&dr, @Alice, 0, 200) == 4, 7357300103011000);
    }
}
//check: EXECUTED

