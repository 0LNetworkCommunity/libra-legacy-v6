
//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(_dr: signer, sender: signer) {
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

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;

    fun main(vm: signer, _: signer) {
      TowerState::epoch_reset(&vm);
      assert!(TowerState::get_fullnode_proofs_in_epoch() == 0, 7257);
    }
}
