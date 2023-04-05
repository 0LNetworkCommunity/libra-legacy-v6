//# init --validators Alice Bob Carol Dave Eve

/// Scenario: happy path, all vals bid, and are performing correctly, and match the size of the validator set.
//# run --admin-script --signers DiemRoot Eve
script {
  use DiemFramework::ProofOfFee;
  use DiemFramework::TestFixtures;
  use Std::Vector;
  use DiemFramework::Jail;
  
  // use DiemFramework::Debug::print;

  fun main(vm: signer, _eve_sig: signer) {
    
    let (val_universe, _their_bids, _their_expiry) = TestFixtures::pof_default(&vm);
    
    // Eve is going to be jailed. Should exclude from the sorting.
    Jail::jail(&vm, @Eve);

    let sorted = ProofOfFee::get_sorted_vals(false);
    let len = Vector::length(&sorted);
    // dropeed one
    assert!(len < Vector::length(&val_universe), 1000);

    // print(&len);
    assert!(len == 4, 1001);

  }
}
