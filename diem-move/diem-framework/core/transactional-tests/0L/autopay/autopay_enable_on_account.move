//# init --validators Alice

// This test is to test enable and disable functionalites of autopay
//! new-transaction
//! sender: alice
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(sender: signer) {
    AutoPay::enable_autopay(&sender);
    assert!(AutoPay::is_enabled(Signer::address_of(&sender)), 0);
    AutoPay::disable_autopay(&sender);
    assert!(!AutoPay::is_enabled(Signer::address_of(&sender)), 1);
  }
}
// check: EXECUTED