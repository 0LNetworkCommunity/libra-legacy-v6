//! account: dummy-prevents-genesis-reload, 100000, 0, validator
//! account: alice, 10000000GAS
//! account: bob, 10000000GAS

// Bob Submits a CORRECT VDF Proof, and that updates the state.

//! new-transaction
//! sender: bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(sender: signer) {
        TowerState::test_helper_init_miner(
            &sender,
            100u64, //difficulty
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol()
        );

        let height = TowerState::test_helper_get_height(@Bob);
        assert!(height==0, 01);

    }
}
// check: EXECUTED

// Bob Submit the Duplicated CORRECT VDF Proof, which he just sent.
//! new-transaction
//! sender: bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(sender: signer) {
        let difficulty = 100;
        let proof = TowerState::create_proof_blob(
            TestFixtures::easy_chal(),
            difficulty,
            TestFixtures::easy_sol()
        );
        TowerState::commit_state(&sender, proof);
    }
}
// check: VMExecutionFailure(ABORTED { code: 33307393