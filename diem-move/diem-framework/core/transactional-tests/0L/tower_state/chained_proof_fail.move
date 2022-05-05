//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

    // SIMULATES A MINER 0 PROOF ADDED IN GENESIS (proof_0.json)
    // The first transaction should succeed, but the second sends a valid 
    // vdf proof but is not matched to previous proof. 
    fun main(sender: signer) {

        let height_after = 0;

        TowerState::test_helper_init_val(
            &sender,
            TestFixtures::easy_chal(),
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );

        // check for initialized TowerState
        let verified_tower_height_after = TowerState::test_helper_get_height(@{{alice}});

        assert(verified_tower_height_after == height_after, 10008001);
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
            // a correct pair, but does not match the previous proof alice sent.
            TestFixtures::easy_chal(),
            
            TestFixtures::easy_sol(),
            TestFixtures::easy_difficulty(),
            TestFixtures::security(),
        );
        TowerState::commit_state(&sender, proof);

        let verified_height = TowerState::test_helper_get_height(@{{alice}});
        assert(verified_height == height_after, 10008002);
    }
}
// check: ABORTED
