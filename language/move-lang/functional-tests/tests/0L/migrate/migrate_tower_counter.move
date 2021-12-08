//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000


// TODO: this test has no effect since the previous state is no longer being initialized in genesis. It's mainly checking that the migration can be called while the state already exists without causing a halt.

//! new-transaction
//! sender: diemroot
script {
    use 0x1::MigrateTowerCounter;
    use 0x1::TowerState;
    // use 0x1::Debug::print;
    fun main(vm: signer) {
      // need to mock the previous state of the network which uses MinerStats
      TowerState::test_mock_depr_tower_stats(&vm);

      // migrate MinerStats to MinerCounter
      MigrateTowerCounter::migrate_tower_counter(&vm);
      assert(TowerState::test_get_liftime_proofs() == 111, 735701);

    }
}
// check: EXECUTED
