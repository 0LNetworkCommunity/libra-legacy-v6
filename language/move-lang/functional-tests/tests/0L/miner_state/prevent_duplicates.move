//! account: dummy-prevents-genesis-reload, 100000, 0, validator
//! account: alice, 10000000GAS
//! account: bob, 10000000GAS

// Bob Submits a CORRECT VDF Proof, and that updates the state.

//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

    fun main(sender: signer) {
        let difficulty = 100;
        let security = 2048;

        TowerState::test_helper_init_miner(
            &sender,
            TestFixtures::alice_0_easy_chal(),
            TestFixtures::alice_0_easy_sol(),
            difficulty,
            security
        );

        let height = TowerState::test_helper_get_height(@{{bob}});
        assert(height==0, 01);

    }
}
// check: EXECUTED

// Bob Submit the Duplicated CORRECT VDF Proof, which he just sent.
//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

    fun main(sender: signer) {
        let difficulty = 100;
        let security = 2048;
        let proof = TowerState::create_proof_blob(
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            difficulty,
            security,
        );
        TowerState::commit_state(&sender, proof);
    }
}
// check: VMExecutionFailure(ABORTED { code: 33307393