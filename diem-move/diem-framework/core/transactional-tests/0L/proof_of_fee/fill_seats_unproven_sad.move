//# init --validators Alice Bob Carol Dave Eve Frank


// Scenario: Here we have 6 validators and 4 seats, but only 4 come
// from the previous epoch.
// This time Eve and Frank are "unproven nodes", they also happen
// to have the highest bids.
// They have all placed bids, per TestFixtures::pof_default().

// At 4 seats, we only have space for 1 unproven node.
// It should be Frank that gets seated.
// Eve will not be seated at all, even though she has a higher bid
// than the proven nodes.

// The clearing price will not change. The lowest is still Alice
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

    // the set size will only allow for 1 unproven node.
    let set_size = 5;

    // Eve and Frank were not in the previous round. They are not "proven"
    let proven_vals = Vector::singleton(@Alice);
    Vector::push_back(&mut proven_vals, @Bob);
    Vector::push_back(&mut proven_vals, @Carol);
    Vector::push_back(&mut proven_vals, @Dave);
    // Vector::push_back(&mut proven_vals, @Eve);
    // Vector::push_back(&mut proven_vals, @Frank);


    let (seats,_p) = ProofOfFee::fill_seats_and_get_price(
      &vm,
      set_size,
      &sorted,
      &proven_vals
    );
    // print(&seats);
    // print(&p);

    
    // Eve is not despite bidding a higher price than many
    assert!(!Vector::contains(&seats, &@Eve), 1001);
    // Frank is in, his bid is higher than Eve's
    // So when the only slot opened up for "unproven" nodes
    // Frank was seated. Frank was competing only with Eve.
    assert!(Vector::contains(&seats, &@Frank), 1002);

    // Alice and Bob are still in as proven nodes, although the bid was lower
    assert!(Vector::contains(&seats, &@Alice), 1003);
    assert!(Vector::contains(&seats, &@Bob), 1004);

    

    // filling the seat updated the computation of the consensu reward.
    // Median bids and clearing prices will be different than the happy path test.
    let (reward, clear_price, median_bid) = ProofOfFee::get_consensus_reward();
    // print(&reward);
    assert!(reward == 1000000, 1005);
    // print(&clear_price);
    // The clearing price is 1, Alice's lowest bid.
    assert!(clear_price == 1, 1006);
    // print(&median_bid);
    assert!(median_bid == 3, 1007);
  }
}
