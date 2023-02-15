//# init --validators Alice Bob Carol

// Scenario: Alice sets a bid, but the epoch expiring is 0,
// the test run on epoch 1. The audit should fail.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::ProofOfFee;
  use DiemFramework::Jail;

  fun main(vm: signer, a_sig: signer) {
    ProofOfFee::set_bid(&a_sig, 100, 0);
    let (bid, expires) = ProofOfFee::current_bid(@Alice);
    assert!(bid == 100, 1001);
    assert!(expires == 0, 1002);
    assert!(!ProofOfFee::audit_qualification(&@Alice), 1003);

    // lets fix that
    ProofOfFee::set_bid(&a_sig, 100, 100);
    assert!(ProofOfFee::audit_qualification(&@Alice), 1004);




  }
}