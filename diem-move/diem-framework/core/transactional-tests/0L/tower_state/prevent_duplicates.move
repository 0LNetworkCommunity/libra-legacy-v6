
//# init --validators DummyPreventsGenesisReload
//#      --addresses Alice=0x2e3a0b7a741dae873bf0f203a82dfd52
//#                  Bob=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Alice=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8
//#                     Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7

//// Old syntax for reference, delete it after fixing this test
//! account: dummy-prevents-genesis-reload, 100000, 0, validator
//! account: alice, 10000000GAS
//! account: bob, 10000000GAS

// Bob Submits a CORRECT VDF Proof, and that updates the state.

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

        let height = TowerState::test_helper_get_height(@Bob);
        assert!(height==0, 01);

    }
}
// check: EXECUTED

// Bob Submit the Duplicated CORRECT VDF Proof, which he just sent.
//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(_dr: signer, sender: signer) {
        let proof = TowerState::create_proof_blob(
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
        TowerState::commit_state(&sender, proof);
    }
}
// check: ABORTED