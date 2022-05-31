//# init --validators DummyPreventsGenesisReload --parent-vasps Alice Bob
// DummyPreventsGenesisReload: validator  with 10M GAS
// Alice, Bob:             non-validators with  1M GAS

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
// Error: Transaction discarded. VMStatus: status ABORTED of type Execution with sub status 130109