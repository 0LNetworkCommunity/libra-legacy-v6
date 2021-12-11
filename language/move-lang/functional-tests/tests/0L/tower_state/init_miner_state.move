//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

// Alice is an end-user, and submits a VDF Proof

//! new-transaction

//! sender: alice
script {
use 0x1::TowerState;
use 0x1::TestFixtures;
use 0x1::Debug::print;
use 0x1::Vector;

fun main(sender: signer) {
    TowerState::init_miner_state(
        &sender,
        &TestFixtures::alice_0_easy_chal(),
        &TestFixtures::alice_0_easy_sol(),
        TestFixtures::easy_difficulty(),
        TestFixtures::security(),
    );

    print(&TowerState::get_epochs_compliant(@{{alice}}));
    assert(TowerState::get_tower_height(@{{alice}}) == 0, 735701);
    assert(TowerState::get_epochs_compliant(@{{alice}}) == 0, 735702);
    assert(TowerState::get_count_in_epoch(@{{alice}}) == 1, 735703);
    print(&TowerState::get_miner_list());
    assert(Vector::length<address>(&TowerState::get_miner_list()) == 2, 735704); // includes the dummy validator from genesis

}
}
// check: EXECUTED


