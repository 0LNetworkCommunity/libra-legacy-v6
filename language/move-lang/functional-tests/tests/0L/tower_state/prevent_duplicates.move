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
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
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