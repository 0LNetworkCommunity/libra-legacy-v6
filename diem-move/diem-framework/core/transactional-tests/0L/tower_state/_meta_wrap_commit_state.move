//# init --validators DummyPreventsGenesisReload --parent-vasps Alice Bob
// DummyPreventsGenesisReload: validator  with 10M GAS
// Alice, Bob:             non-validators with  1M GAS

// Prepare the state for the next test.
// Bob Submits a CORRECT VDF Proof, and that updates the state.

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(_dr: signer, sender: signer) {
        // Testing that state can be initialized, and a proof submitted as if it were genesis.
        // buildign block for other tests.
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