
//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0



//! new-transaction
//! sender: bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(sender: signer) {
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
    }
}



//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


// Clear the global proof count in epoch.

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::TowerState;

    fun main(_: signer) {
      // TowerState::epoch_reset(&vm);
      assert!(TowerState::get_fullnode_proofs_in_epoch() == 0, 725701);
      assert!(TowerState::get_fullnode_proofs_in_epoch_above_thresh() == 0, 72570);

    }
}
