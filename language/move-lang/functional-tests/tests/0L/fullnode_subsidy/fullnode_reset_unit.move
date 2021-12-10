
//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS, 0



//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

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


// Clear the global proof count in epoch.

//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;

    fun main(vm: signer) {
      TowerState::epoch_reset(&vm);
      assert(TowerState::get_fullnode_proofs_in_epoch() == 0, 7257);
    }
}
