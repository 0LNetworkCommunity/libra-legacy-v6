//! account: dummy-prevents-genesis-reload, 100000 ,0, validator
//! account: alice, 10000000GAS

// Alice Submit VDF Proof
//! new-transaction
//! sender: alice
script {
use 0x0::MinerState;
// use 0x0::Debug;
use 0x0::Transaction;
use 0x0::TestFixtures;


// SIMULATES A MINER ONBOARDING PROOF (block_0.json)
fun main(sender: &signer) {
    let difficulty = 100;
    let height_after = 0;

    // return solution
    MinerState::test_helper(
        sender,
        difficulty,
        TestFixtures::alice_0_easy_chal(),
        TestFixtures::alice_0_easy_sol()
    );

    // check for initialized MinerState
    let verified_tower_height_after = MinerState::test_helper_get_height({{alice}});

    Transaction::assert(verified_tower_height_after == height_after, 10008001);

}
}
// check: EXECUTED


//! new-transaction
//! sender: alice
script {
use 0x0::MinerState;
use 0x0::Transaction;
use 0x0::TestFixtures;

// SIMULATES THE SECOND PROOF OF THE MINER (block_1.json)
fun main(sender: &signer) {
    let difficulty = 100u64;
    Transaction::assert(MinerState::test_helper_get_height({{alice}}) == 0, 10008001);
    let height_after = 1;
    
    let proof = MinerState::create_proof_blob(
        TestFixtures::alice_1_easy_chal(),
        difficulty,
        TestFixtures::alice_1_easy_sol()
    );
    MinerState::commit_state(sender, proof);

    let verified_height = MinerState::test_helper_get_height({{alice}});
    Transaction::assert(verified_height == height_after, 10008002);
}
}
// check: EXECUTED


//! new-transaction
//! sender: association
script {
use 0x0::MinerState;
use 0x0::Transaction;

// Simulating the VM calling epoch boundary update_metrics.
fun main(_sender: &signer) {
    //update_metrics
    // reference:
    //  previous_proof_hash: vector<u8>,
    // verified_tower_height: u64, // user's latest verified_tower_height
    // latest_epoch_mining: u64,
    // count_proofs_in_epoch: u64,
    // epochs_validating_and_mining: u64,
    // contiguous_epochs_validating_and_mining: u64,

    Transaction::assert(MinerState::test_helper_get_height({{alice}}) == 1, 10009001);
    Transaction::assert(MinerState::get_miner_latest_epoch({{alice}}) == 1, 10009002);
    Transaction::assert(MinerState::test_helper_get_count({{alice}}) == 2, 10009003);
    Transaction::assert(MinerState::test_helper_get_miner_epochs({{alice}}) == 0, 10009004);
    Transaction::assert(MinerState::test_helper_get_contiguous({{alice}}) == 0, 10009005);
    
    MinerState::test_helper_update_metrics({{alice}});

    Transaction::assert(MinerState::test_helper_get_height({{alice}}) == 1, 10009006);
    Transaction::assert(MinerState::get_miner_latest_epoch({{alice}}) == 1, 10009007);
    Transaction::assert(MinerState::test_helper_get_count({{alice}}) == 0, 10009008);
    Transaction::assert(MinerState::test_helper_get_miner_epochs({{alice}}) == 1, 10009009);
    Transaction::assert(MinerState::test_helper_get_contiguous({{alice}}) == 1, 10009010);

}
}
// check: EXECUTED

