//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

    // SIMULATES A MINER ONBOARDING PROOF (proof_0.json)
    fun main(sender: signer) {
        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::alice_0_easy_chal(),
            TestFixtures::alice_0_easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        assert(TowerState::test_helper_get_height(@{{alice}}) == 0, 10008001);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;
    // SIMULATES THE SECOND PROOF OF THE MINER (proof_1.json)
    fun main(sender: signer) {
        assert(TowerState::test_helper_get_height(@{{alice}}) == 0, 10008001);
        let height_after = 1;
        let proof = TowerState::create_proof_blob(
            TestFixtures::alice_1_easy_chal(),
            TestFixtures::alice_1_easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        TowerState::commit_state(&sender, proof);
        let verified_height = TowerState::test_helper_get_height(@{{alice}});
        assert(verified_height == height_after, 10008002);
    }
}
// check: EXECUTED

