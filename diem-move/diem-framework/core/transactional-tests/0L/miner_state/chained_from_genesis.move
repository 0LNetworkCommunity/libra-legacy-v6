//# init --validators Alice

// Alice Submit VDF Proof

//# run --admin-script --signers DiemRoot Alice
script {
use DiemFramework::TowerState;
use DiemFramework::TestFixtures;
use DiemFramework::Debug::print;

// SIMULATES THE SECOND PROOF OF THE MINER (block_1.json)
fun main(_dr: signer, sender: signer) {
    print(&780001);

    assert!(TowerState::test_helper_get_height(@Alice) == 0, 10008001);
    assert!(
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

    assert!(TowerState::test_helper_get_height(@Alice) == 1, 10008003);
    print(&780009);
}
}