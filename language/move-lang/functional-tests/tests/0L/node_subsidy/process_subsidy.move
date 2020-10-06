//! account: alice, 1, 0, validator
//! account: bob, 1, 0, validator
//! account: carol, 1, 0, validator
//! account: dave, 1, 0, validator

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
//! sender: association
script {
  // use 0x0::Transaction;
  use 0x0::Subsidy;
  use 0x0::Vector;
  use 0x0::AltStats;
  use 0x0::Transaction::assert;
  // use 0x0::Debug::print;
  use 0x0::GAS;
  use 0x0::LibraAccount;

  fun main(sender: &signer) {
    // check the case of a network density of 4 active validators.

    let validators = Vector::singleton<address>({{alice}});
    Vector::push_back(&mut validators, {{bob}});
    Vector::push_back(&mut validators, {{carol}});
    Vector::push_back(&mut validators, {{dave}});    

    // create mock validator stats for full epoch
    let i = 0;
    while (i < 16) {
      AltStats::process_set_votes(&validators);
      i = i + 1;
    };

    Subsidy::process_subsidy(sender, 100);

    // print(&LibraAccount::balance<GAS::T>({{alice}}));
    assert(LibraAccount::balance<GAS::T>({{alice}}) == 101, 7357000001);
    assert(LibraAccount::balance<GAS::T>({{bob}}) == 1, 7357000002);
  }
}
// check: EXECUTED
