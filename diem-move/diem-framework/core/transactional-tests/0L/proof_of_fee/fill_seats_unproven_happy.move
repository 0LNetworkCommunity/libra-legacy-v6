//# init --validators Alice Bob Carol Dave Eve Frank


// Scenario: Here we have 6 validators and 6 seats, but only 4 come
// from the previous epoch.
// They have all placed bids, per TestFixtures::pof_default().

// However Alice and Bob have not been in the last epoch's set.
// So we consider them "unproven".
// Alice and Bob happen to also be the lowest bidders. But we will
// seat them, and their bids will count toward getting the clearing price.

// In this scenario there will be sufficient seats. 
// We will open up 2 seats (1/3 of 6 seats).
// As such both Eve and Frank should be seated.

// The clearing price will not change. The lowest is still alice
// who is also seated.


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
    assert!(len == 6, 1000);
    
    // The desired validator set is exaclty the size of the elegible validators, who all have placed bids.
    // the performant validators are the same as the bidding validators.

    // our set is big enough that we can include 2 unproven nodes (1/3).
    let set_size = 6;

    // Alice and Bob were not in the previous round. They are not "proven"
    let proven_vals = Vector::singleton(@Carol);
    Vector::push_back(&mut proven_vals, @Dave);
    Vector::push_back(&mut proven_vals, @Eve);
    Vector::push_back(&mut proven_vals, @Frank);


    let (seats, _p) = ProofOfFee::fill_seats_and_get_price(
      &vm,
      set_size,
      &sorted,
      &proven_vals
    );
    // print(&seats);
    // print(&p);

    // Alice and Bob must be in
    assert!(Vector::contains(&seats, &@Alice), 1001);
    assert!(Vector::contains(&seats, &@Bob), 1002);
    assert!(Vector::contains(&seats, &@Carol), 1003);

    // filling the seat updated the computation of the consensu reward.
    // Median bids and clearing prices will be different than the happy path test.
    let (reward, clear_price, median_bid) = ProofOfFee::get_consensus_reward();
    // print(&reward);
    assert!(reward == 1000000, 1004);
    // print(&clear_price);
    // The clearing price is 1, Alice's lowest bid.
    assert!(clear_price == 1, 1005);
    // print(&median_bid);
    assert!(median_bid == 3, 1006);
  }
}
