//! account: bob, 1000000, 0, validator

// tests that at round 3 (The round after an upgrade) state is migrated.

// 1. create the state which needs to be migrated from e.g TowerStats which is now deprecated.

//! block-prologue
//! proposer: bob
//! block-time: 1
//! round: 1


//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    use 0x1::Debug::print;
    fun main(vm: signer) {
      // remove the TowerCounter state to mock the state of the network before the upgrade.
      TowerState::test_danger_destroy_tower_counter(&vm);
      // need to mock the previous state of the network which uses MinerStats
      TowerState::test_mock_depr_tower_stats(&vm);

      // migrate MinerStats to MinerCounter
      let (migrate_proofs, _, _) = TowerState::danger_migrate_get_lifetime_proof_count();
      print(&migrate_proofs);
      assert(migrate_proofs== 111, 735701);

    }
}
// check: EXECUTED

// 2. make the migration happen on round 3

////////////// TRIGGER ROUND 3, WHEN MIGRATIONS HAPPEN ///////////////
//! block-prologue
//! proposer: bob
//! block-time: 10
//! round: 3


// 3. Check that the migration occurred and the mock data is correct

//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    fun main(_: signer) {
      
      assert(TowerState::test_get_liftime_proofs() == 111, 735701);
    }
}
// check: EXECUTED