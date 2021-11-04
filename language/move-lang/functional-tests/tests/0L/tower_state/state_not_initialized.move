// Scenario: Alice is NOT a validator, and has not mined before. she tries to submit proof_0.json the genesis proof without any TowerState being initialized. The tx should abort.

//! account: dummy-prevents-genesis-reload, 100000 ,0, validator

// Alice Submit VDF Proof
//! new-transaction
//! account: alice, 10000000GAS
//! sender: alice
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

    fun main(sender: signer) {

        // return solution
        let proof = TowerState::create_proof_blob(
          TestFixtures::alice_0_easy_chal(),
          TestFixtures::alice_0_easy_sol(),
          TestFixtures::easy_difficulty(),
          TestFixtures::security(),
        );
        TowerState::commit_state(&sender, proof);

        let verified_tower_height_after = TowerState::test_helper_get_height(@{{alice}});

        assert(verified_tower_height_after == 0, 7357001);
    }
}


