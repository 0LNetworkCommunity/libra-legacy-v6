//! account: alice, 100000GAS,0, validator

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice

script {
use 0x0::MinerState;
use 0x0::Transaction;
use 0x0::TestFixtures;
// use 0x0::Debug;


// SIMULATES THE SECOND PROOF OF THE MINER (block_1.json)
fun main(sender: &signer) {
    let difficulty = 100u64;
    Transaction::assert(MinerState::test_helper_get_height({{alice}}) == 0, 10008001);
    Transaction::assert(MinerState::test_helper_hash({{alice}}) == TestFixtures::alice_1_easy_chal(), 10008002);
        
    let proof = MinerState::create_proof_blob(
        TestFixtures::alice_1_easy_chal(),
        difficulty,
        TestFixtures::alice_1_easy_sol()
    );
    MinerState::commit_state(sender, proof);
    Transaction::assert(MinerState::test_helper_get_height({{alice}}) == 1, 10008003);
}
}
// check: EXECUTED
