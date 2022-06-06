//# init --validators DummyPreventsGenesisReload --parent-vasps Bob
// DummyPreventsGenesisReload: validator  with 10M GAS
// Bob:                    non-validator with  1M GAS

// Scenario: Alice is NOT a validator, and has not mined before. 
// she tries to submit proof_0.json the genesis proof without any TowerState
// being initialized. The tx should abort.

// TODO: THERE'S NO CLEAR WAY TO TEST THE AFFIRMATIVE CASE OF THIS in
// functional test suite. The accounts created above have random addresses,
// and we need fixed addresses in the proof preimage. This tests at least that
// someone cannot send a transaction with someone else's genesis proof.

// BOB Submits ALICE's GENESIS VDF Proof
//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TowerState;
    use DiemFramework::TestFixtures;

    fun main(_dr: signer, sender: signer) {
        // return solution
        let proof = TowerState::create_proof_blob(
          TestFixtures::alice_0_easy_chal(), // THIS IS THE WRONG USER. Forging a tower.
          TestFixtures::alice_0_easy_sol(),
          TestFixtures::easy_difficulty(),
          TestFixtures::security(),
        );
        TowerState::commit_state(&sender, proof);

        let verified_tower_height_after = TowerState::test_helper_get_height(@Bob);

        assert!(verified_tower_height_after == 0, 7357001);
    }
}