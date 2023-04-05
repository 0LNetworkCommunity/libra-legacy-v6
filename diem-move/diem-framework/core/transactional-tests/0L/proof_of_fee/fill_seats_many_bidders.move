//# init --validators Alice Bob Carol Dave Eve


/// Scenario: We have 5 validators but only 3 seats in the set.
/// They have all placed bids, per TestFixtures::pof_default().
// The lowest bidders Alice and Bob, will be excluded.

/// For all lists we are using the validators in the ValidatorUniverse
/// the desired validator set is the same size as the universe.
/// All validators in the universe are properly configured
/// All validators performed perfectly in the previous epoch.


//# run --admin-script --signers DiemRoot Eve
script {
  use DiemFramework::ProofOfFee;
  use DiemFramework::TestFixtures;
  use Std::Vector;
  
  // use DiemFramework::Debug::print;

  fun main(vm: signer, _eve_sig: signer) {
    
    let (_val_universe, _their_bids, _their_expiry) = TestFixtures::pof_default(&vm);

    let sorted = ProofOfFee::get_sorted_vals(false);
    let len = Vector::length(&sorted);

    // print(&len);
    // all validators are ready and have qualifying bids.
    assert!(len == 5, 1000);
    
    // The desired validator set is exaclty the size of the elegible validators, who all have placed bids.
    // the performant validators are the same as the bidding validators.

    // 
    let set_size = 3;
    let (seats, _p) = ProofOfFee::fill_seats_and_get_price(
      &vm,
      set_size,
      &sorted,
      &sorted
    );
    // print(&seats);
    // print(&p);

    assert!(!Vector::contains(&seats, &@Alice), 1001);
    assert!(!Vector::contains(&seats, &@Bob), 1002);
    // carol is in
    assert!(Vector::contains(&seats, &@Carol), 1003);

    // filling the seat updated the computation of the consensu reward.
    // Median bids and clearing prices will be different than the happy path test.
    let (reward, clear_price, median_bid) = ProofOfFee::get_consensus_reward();
    // print(&reward);
    assert!(reward == 1000000, 1004);
    // print(&clear_price);
    assert!(clear_price == 3, 1005);
    // print(&median_bid);
    assert!(median_bid == 5, 1006);
  }
}
