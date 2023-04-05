//# init --validators Alice

// Scenario: The reward is too high during 5 days (short window). People are bidding over 95% of the baseline fee.


//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::ProofOfFee;
  // use DiemFramework::Debug::print;
  use Std::Vector;

  fun main(vm: signer, _a_sig: signer) {
    
    let start_value = 0960; // 96% of baseline fee. 
    let median_history = Vector::empty<u64>(); 

    // we need at least 10 epochs above the 95% range.
    let i = 0;
    while (i < 12) {
      // let factor = i * 10;
      // let value = start_value + factor;
      // // print(&value);
      Vector::push_back(&mut median_history, start_value);
      i = i + 1;
    };


    ProofOfFee::test_mock_reward(
      &vm,
      100,
      50,
      33,
      median_history,
    ); 

    // no changes until we run the thermostat.
    let (value, clearing, median) = ProofOfFee::get_consensus_reward();
    assert!(value == 100, 1000);
    assert!(clearing == 50, 1001);
    assert!(median == 33, 1002);

    ProofOfFee::reward_thermostat(&vm);

    // In the decrease case during a short period, we decrease by 5%
    // No other parameters of consensus reward should change on calling this function.
    let (value, clearing, median) = ProofOfFee::get_consensus_reward();
    assert!(value == 90, 1000);
    assert!(clearing == 50, 1001);
    assert!(median == 33, 1002);

    // print(&value);
    // print(&clearing);
    // print(&median);

  }
}
