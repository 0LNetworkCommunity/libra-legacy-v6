//! account: alice, 100000GAS,0, validator

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice

script {
use 0x1::MinerState;
use 0x1::TestFixtures;
use 0x1::Debug::print;
use 0x1::Signer;
// use 0x1::Hash;
// SIMULATES THE SECOND PROOF OF THE MINER (block_1.json)
fun main(sender: &signer) {
    print(&{{alice}});
    print(&Signer::address_of(sender));

    let difficulty = 100u64;
    assert(MinerState::test_helper_get_height({{alice}}) == 0, 10008001);
    assert(MinerState::test_helper_hash({{alice}}) == TestFixtures::alice_1_easy_chal(), 10008002);
        
    let proof = MinerState::create_proof_blob(
        TestFixtures::alice_1_easy_chal(),
        difficulty,
        TestFixtures::alice_1_easy_sol()
    );
    MinerState::commit_state(sender, proof);

    assert(MinerState::test_helper_get_height({{alice}}) == 1, 10008003);
}
}
// check: EXECUTED
