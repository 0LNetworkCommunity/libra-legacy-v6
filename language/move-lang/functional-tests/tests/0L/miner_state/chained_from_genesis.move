//! account: alice, 100000GAS,0, validator

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice
//! gas-currency: GAS

script {
use 0x1::TowerState;
use 0x1::TestFixtures;
// SIMULATES THE SECOND PROOF OF THE MINER (proof_1.json)
fun main(sender: signer) {

    assert(TowerState::test_helper_get_height(@{{alice}}) == 0, 10008001);
    assert(
        TowerState::test_helper_previous_proof_hash(&sender) 
            == TestFixtures::alice_1_easy_chal(),
        10008002
    );
        
    let proof = TowerState::create_proof_blob(
        TestFixtures::alice_1_easy_chal(),
        TestFixtures::alice_1_easy_sol(),
        TestFixtures::easy_difficulty(),
        TestFixtures::security(),
    );
    TowerState::commit_state(&sender, proof);

    assert(TowerState::test_helper_get_height(@{{alice}}) == 1, 10008003);
}
}
// check: EXECUTED
