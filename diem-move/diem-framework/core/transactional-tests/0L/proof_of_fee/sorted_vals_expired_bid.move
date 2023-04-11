//# init --validators Alice Bob Carol Dave Eve

/// Scenario: Eve decides to withdraw bid. Otherwise all vals are performing correctly, and match the size of the validator set.

//# run --admin-script --signers DiemRoot Eve
script {
  use DiemFramework::ProofOfFee;
  use DiemFramework::TestFixtures;
  use Std::Vector;
  
  // // use DiemFramework::Debug::print;

  fun main(vm: signer, eve_sig: signer) {
    
    let (val_universe, _their_bids, _their_expiry) = TestFixtures::pof_default(&vm);
    // Ok now Eve changes her mind. Will force the bid to expire.
    // asser
    ProofOfFee::set_bid(&eve_sig, 0, 0);
    let sorted = ProofOfFee::get_sorted_vals(false);
    let len = Vector::length(&sorted);

    assert!(len < Vector::length(&val_universe), 1000);
    assert!(!Vector::contains(&sorted, &@Eve), 1001);
    assert!(len == 4, 1002);


  }
}



// /// Scenario: Eve does not bid. So we have fewer bidders than seats
// //# run --admin-script --signers DiemRoot Eve
// script {
//   use DiemFramework::ProofOfFee;
//   use DiemFramework::TestFixtures;
//   use Std::Vector;
  
//   // use DiemFramework::Debug::print;

//   fun main(vm: signer, _eve_sig: signer) {
    
//     let (_val_universe, _their_bids, _their_expiry) = TestFixtures::pof_default(&vm);
//     // Ok now Eve changes her mind. Will force the bid to expire.
//     ProofOfFee::set_bid(&eve_sig, 0, 1);

//     let sorted = ProofOfFee::get_sorted_vals();
//     let len = Vector::length(&sorted);

//     // print(&len);
//     assert!(len == 4, 1000);


//   }
// }
