//# init --validators DummyPreventsGenesisReload --parent-vasps Alice
// DummyPreventsGenesisReload: validator with 10M GAS
// Alice:                  non-validator with  1M GAS

// Alice is an end-user, and submits a VDF Proof

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;
    // use DiemFramework::Debug::print;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
        TowerState::init_miner_state(
            &sender,
            &TestFixtures::alice_0_easy_chal(),
            &TestFixtures::alice_0_easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        // print(&TowerState::get_epochs_compliant(@Alice));
        assert!(TowerState::get_tower_height(@Alice) == 0, 735701);
        assert!(TowerState::get_epochs_compliant(@Alice) == 0, 735702);
        assert!(TowerState::get_count_in_epoch(@Alice) == 1, 735703);
        // print(&TowerState::get_miner_list());
        assert!(Vector::length<address>(&TowerState::get_miner_list()) == 2, 735704); 
            // includes the dummy validator from genesis
    }
}
// check: EXECUTED