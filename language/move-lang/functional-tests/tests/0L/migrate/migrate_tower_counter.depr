//! account: alice, 1000000, 0, validator


//! new-transaction
//! sender: diemroot
script {
    use 0x1::MigrateTowerCounter;
    use 0x1::TowerState;
    fun main(vm: signer) {
      // remove the TowerCounter state to mock the state of the network before the upgrade.
      TowerState::test_danger_destroy_tower_counter(&vm);
      // need to mock the previous state of the network which uses MinerStats
      TowerState::test_mock_depr_tower_stats(&vm);

      // migrate MinerStats to MinerCounter
      MigrateTowerCounter::migrate_tower_counter(&vm);
      
      assert(TowerState::test_get_liftime_proofs() == 111, 735701);

    }
}
// check: EXECUTED
