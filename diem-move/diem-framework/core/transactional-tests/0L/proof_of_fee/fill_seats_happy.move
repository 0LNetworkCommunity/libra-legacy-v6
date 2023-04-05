//# init --validators Alice Bob Carol Dave Eve


/// Scenario: Happy Day
/// For all lists we are using the validators in the ValidatorUniverse
/// the desired validator set is the same size as the universe.
/// All validators in the universe are properly configured
/// All validators performed perfectly in the previous epoch.
/// They have all placed bids, per TestFixtures::pof_default().

//# run --admin-script --signers DiemRoot Eve
script {
  use DiemFramework::ProofOfFee;
  use DiemFramework::TestFixtures;
  use Std::Vector;

  // use DiemFramework::Debug::print;

  fun main(vm: signer, _a_sig: signer) {
    
    let (val_universe, _their_bids, _their_expiry) = TestFixtures::pof_default(&vm);

    let sorted = ProofOfFee::get_sorted_vals(false);
    let len = Vector::length(&sorted);

    assert!(len == Vector::length(&val_universe), 1000);
    
    // The desired validator set is exaclty the size of the elegible validators, who all have placed bids.
    // the performant validators are the same as the bidding validators.
    let (seats, _p) = ProofOfFee::fill_seats_and_get_price(&vm, len, &sorted, &sorted);
    // print(&seats);
    // print(&p);

    assert!(Vector::contains(&seats, &@Alice), 1000);

    // filling the seat updated the computation of the consensu reward.
    let (reward, clear_price, median_bid) = ProofOfFee::get_consensus_reward();
    assert!(reward == 1000000, 1001);
    assert!(clear_price == 1, 1002);
    // print(&median_bid);
    assert!(median_bid == 3, 1003);


  }
}
