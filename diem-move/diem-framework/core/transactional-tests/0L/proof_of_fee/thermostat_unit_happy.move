//# init --validators Alice

// Scenario: Happy path: The median history is fully within range of 50%-95% of baseline reward. No change is epected.


//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::ProofOfFee;
  // use DiemFramework::Debug::print;
  use Std::Vector;

  fun main(vm: signer, _a_sig: signer) {
    
    let start_value = 0510; // 51% of baseline reward
    let median_history = Vector::empty<u64>(); 

    let i = 0;
    while (i < 10) {
      let factor = i * 10;
      let value = start_value + factor;
      // print(&value);
      Vector::push_back(&mut median_history, value);
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

    // This is the happy case. No changes since the rewards were within range
    // the whole time.
    let (value, clearing, median) = ProofOfFee::get_consensus_reward();
    assert!(value == 100, 1000);
    assert!(clearing == 50, 1001);
    assert!(median == 33, 1002);



  }
}
