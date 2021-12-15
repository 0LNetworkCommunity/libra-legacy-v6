//! account: alice, 1, 0, validator
//! account: bob, 1, 0



//! sender: bob
script {
use 0x1::TowerState;
use 0x1::TestFixtures;
// use 0x1::Debug::print;
// use 0x1::Vector;

fun main(sender: signer) {
    TowerState::init_miner_state(
        &sender,
        &TestFixtures::alice_0_easy_chal(),
        &TestFixtures::alice_0_easy_sol(),
        TestFixtures::easy_difficulty(),
        TestFixtures::security(),
    );
}
}
// check: EXECUTED


    // public(script) fun minerstate_commit(
    //     sender: signer,
    //     challenge: vector<u8>, 
    //     solution: vector<u8>,
    //     difficulty: u64,
    //     security: u64,

// continue from genesis with proof_1

//! new-transaction
//! sender: bob
//! args: x"19b7be4956ca7cb08a981ce38c30afd5a3f9699d716b606e447c32daa06d9074", x"002b1970e1ccc00707639ad5bd5228e61567074043a0c897563c10249580abd776ffdc2e76b8d49d2d639ef5544bdb713abab00d74490e7759788d0c6bf6df6be59d", 100, 512
stdlib_script::TowerStateScripts::minerstate_commit
// check: "Keep(EXECUTED)"
