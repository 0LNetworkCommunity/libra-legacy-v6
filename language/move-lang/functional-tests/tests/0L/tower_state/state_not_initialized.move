// Scenario: Alice is NOT a validator, and has not mined before. she tries to submit proof_0.json the genesis proof without any TowerState being initialized. The tx should abort.

//! account: dummy-prevents-genesis-reload, 100000, 0, validator
//! account: bob, 10000000GAS

// TODO: THERE'S NO CLEAR WAY TO TEST THE AFFIRMATIVE CASE OF THIS in functional test suite
// The accounts created above have random addresses, and we need fixed addresses in the proof preimage.
// this tests at least that someone cannot send a transaction with someone else's genesis proof.

// BOB Submits ALICE's GENESIS VDF Proof
//! new-transaction
//! sender: bob
script {
    use 0x1::TowerState;
    use 0x1::TestFixtures;

    fun main(sender: signer) {

        // return solution
        let proof = TowerState::create_proof_blob(
          TestFixtures::alice_0_easy_chal(), // THIS IS THE WRONG USER. Forging a tower.
          TestFixtures::alice_0_easy_sol(),
          TestFixtures::easy_difficulty(),
          TestFixtures::security(),
        );
        TowerState::commit_state(&sender, proof);

        let verified_tower_height_after = TowerState::test_helper_get_height(@{{bob}});

        assert(verified_tower_height_after == 0, 7357001);
    }
}
//check: VMExecutionFailure(ABORTED 