//# init --validators DummyPreventsGenesisReload
//#      --addresses Alice=0x2e3a0b7a741dae873bf0f203a82dfd52
//#      --private-keys Alice=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8
    // todo: Make Alice non-validator
//// Old syntax for reference, delete it after fixing this test
//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

// Alice is an end-user, and submits a VDF Proof

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;
    use DiemFramework::Debug::print;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
        TowerState::init_miner_state(
            &sender,
            &TestFixtures::alice_0_easy_chal(),
            &TestFixtures::alice_0_easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        print(&TowerState::get_epochs_compliant(@Alice));
        assert!(TowerState::get_tower_height(@Alice) == 0, 735701);
        assert!(TowerState::get_epochs_compliant(@Alice) == 0, 735702);
        assert!(TowerState::get_count_in_epoch(@Alice) == 1, 735703);
        print(&TowerState::get_miner_list());
        assert!(Vector::length<address>(&TowerState::get_miner_list()) == 2, 735704); 
            // includes the dummy validator from genesis
    }
}
// check: EXECUTED