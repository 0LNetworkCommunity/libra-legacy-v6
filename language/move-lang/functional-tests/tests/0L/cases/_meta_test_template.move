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
    use 0x0::MinerState;
    use 0x0::TestFixtures;
    fun main(sender: &signer) {
      //NOTE: Alice is Case 1, she validates and mines. Setting up mining.
        let proof = MinerState::create_proof_blob(
            TestFixtures::alice_1_easy_chal(),
            100u64, // difficulty
            TestFixtures::alice_1_easy_sol()
        );
        MinerState::commit_state(sender, proof);
    }
}
//check: EXECUTED


//! new-transaction
//! sender: carol
script {
    use 0x0::MinerState;
    use 0x0::TestFixtures;
    fun main(sender: &signer) {
      //NOTE: Carol is Case 3, she mines but does not validate. Setting up mining.
        let proof = MinerState::create_proof_blob(
            TestFixtures::alice_1_easy_chal(),
            100u64, // difficulty
            TestFixtures::alice_1_easy_sol()
        );
        MinerState::commit_state(sender, proof);
    }
}
//check: EXECUTED

//! new-transaction
//! sender: association
script {
  // use 0x0::Transaction;
  // use 0x0::Subsidy;
  use 0x0::Vector;
  use 0x0::Stats;
  use 0x0::Transaction::assert;
  // use 0x0::Debug::print;
  use 0x0::GAS;
  use 0x0::LibraAccount;
  use 0x0::Cases;

  fun main(_sender: &signer) {
    // check the case of a network density of 4 active validators.

    let validators = Vector::singleton<address>({{alice}});
    Vector::push_back(&mut validators, {{bob}});

    // create mock validator stats for full epoch
    let i = 0;
    while (i < 16) {
      Stats::process_set_votes(&validators);
      i = i + 1;
    };

    assert(LibraAccount::balance<GAS::T>({{alice}}) == 1, 7357300102011000);
    assert(LibraAccount::balance<GAS::T>({{bob}}) == 1, 7357300102021000);
    assert(LibraAccount::balance<GAS::T>({{carol}}) == 1, 7357300102031000);
    assert(LibraAccount::balance<GAS::T>({{dave}}) == 1, 7357300102041000);

    assert(Cases::get_case({{alice}}) == 1, 7357300102051000);
    assert(Cases::get_case({{bob}}) == 2, 7357300102061000);
    assert(Cases::get_case({{carol}}) == 3, 7357300102071000);
    assert(Cases::get_case({{dave}}) == 4, 7357300102081000);
  }
}
// check: EXECUTED
