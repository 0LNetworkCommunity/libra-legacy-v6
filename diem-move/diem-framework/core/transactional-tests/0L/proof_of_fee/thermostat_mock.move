//# init --validators Alice Bob Carol Dave Eve

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::ProofOfFee;
  use Std::Vector;

  fun main(vm: signer, _bob_sig: signer) {
    ProofOfFee::test_mock_reward(
      &vm,
      100,
      50,
      33,
      Vector::singleton(33),
    ); 

    let (value, clearing, median) = ProofOfFee::get_consensus_reward();
    assert!(value == 100, 1000);
    assert!(clearing == 50, 1001);
    assert!(median == 33, 1002);

  }
}
