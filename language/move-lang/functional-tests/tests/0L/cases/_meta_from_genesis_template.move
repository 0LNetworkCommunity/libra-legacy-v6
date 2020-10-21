// ALICE is CASE 1
//! account: alice, 1, 0, validator

// BOB is CASE 2
//! account: bob, 1, 0, validator

// BOB is CASE 3
//! account: carol, 1, 0, validator

// BOB is CASE 4
//! account: dave, 1, 0, validator

//! new-transaction
//! sender: alice
script {
    use 0x1::MinerState;
    // use 0x1::TestFixtures;
    fun main(sender: &signer) {
      //NOTE: Alice is Case 1, she validates and mines. Setting up mining.
        // let proof = MinerState::create_proof_blob(
        //     TestFixtures::alice_1_easy_chal(),
        //     100u64, // difficulty
        //     TestFixtures::alice_1_easy_sol()
        // );
        // MinerState::commit_state(sender, proof);

        // MinerState::init_miner_state(sender);
        MinerState::test_helper_mock_mining(sender, 5);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: carol
script {
    use 0x1::MinerState;
    // use 0x1::TestFixtures;
    fun main(sender: &signer) {
      //NOTE: Carol is Case 3, she mines but does not validate. Setting up mining.
        // MinerState::init_miner_state(sender);
        MinerState::test_helper_mock_mining(sender, 5);
    }
}
//check: EXECUTED

