// This test is to check if subsidy calculations are impacted by dummy node statistics.

// NOTE: We are creating 7 validators.
//! account: alice, 1, 0, validator
//! account: bob, 1, 0, validator



//! new-transaction
//! sender: alice
script {
    use 0x0::MinerState;
    use 0x0::TestFixtures;

    fun main(sender: &signer) {
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
//! sender: bob
script {
    use 0x0::MinerState;
    use 0x0::TestFixtures;

    fun main(sender: &signer) {
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
  use 0x0::AltStats;
  use 0x0::Transaction::assert;
  use 0x0::Debug::print;
  // use 0x0::GAS;
  use 0x0::FixedPoint32;
  use 0x0::LibraSystem;


  fun main() {
    // check the case of a network density of 4 active validators.

    let validators = Vector::singleton<address>({{alice}});
    Vector::push_back(&mut validators, {{bob}});

    // create mock validator stats for full epoch
    let i = 0;
    while (i < 16) {
      AltStats::process_set_votes(&validators);
      i = i + 1;
    };

    let (validators, fee_ratios, total_votes) = LibraSystem::get_fee_ratio();
    assert(1==1, 1);
    assert(Vector::length(&validators) == 2, 1);
    assert(Vector::length(&fee_ratios) == 2, 1);
    assert(*(Vector::borrow<FixedPoint32::T>(&fee_ratios, 1)) == FixedPoint32::create_from_raw_value(2147483648u64), 1);

    // assert(total_votes == 16, 1);
    print(&validators);
    print(&fee_ratios);
    print(&total_votes);

  }
}
// check: EXECUTED
