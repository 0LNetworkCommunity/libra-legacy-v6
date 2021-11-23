//! account: alice, 0GAS, 0, validator
//! account: eve, 0GAS, 0

// 1. eve is an end-user miner, initialized mining

//! new-transaction
//! sender: eve
script {

  // use 0x1::Teams;
  // use 0x1::DiemAccount;
  use 0x1::TowerState;
  use 0x1::TestFixtures;

  fun main(eve: signer) {
    // DiemAccount::set_slow(&eve);
    // Teams::join_team(&eve, @{{alice}}); // alice's account is the ID of the tribe 

    // eve initializes miner state, will later mine
    TowerState::init_miner_state(
        &eve,
        &TestFixtures::eve_0_easy_chal(),
        &TestFixtures::eve_0_easy_sol(),
        TestFixtures::easy_difficulty(),
        TestFixtures::security(),
    );

  }
}
// check: EXECUTED


// 1. VM mocks alice and eve mining, check cumulative calc.

//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    use 0x1::Vector;
    use 0x1::Debug::print;

    fun main(sender: signer) {
        let sender = &sender;

        // mock mining above threshold
        TowerState::test_helper_mock_mining_vm(sender, @{{alice}}, 500);
        let h = TowerState::get_tower_height(@{{alice}});
        print(&h);

        TowerState::test_helper_mock_mining_vm(sender, @{{eve}}, 500);
        let h = TowerState::get_tower_height(@{{eve}});
        print(&h);

        let members = Vector::singleton<address>(@{{alice}});
        Vector::push_back<address>(&mut members, @{{eve}});
        let collective = TowerState::collective_tower_height(&members);
        print(&collective);
        assert(collective == 1000, 735705);


    }
}
//check: EXECUTED