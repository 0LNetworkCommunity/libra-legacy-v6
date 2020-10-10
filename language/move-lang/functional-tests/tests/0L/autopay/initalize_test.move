//! account: alice, 1000000

// This test is to test enable and disable functionalites of autopay
//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    AutoPay::enable_autopay();
    Transaction::assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    AutoPay::disable_autopay();
    Transaction::assert(!AutoPay::is_enabled(Signer::address_of(sender)), 1);
  }
}
// check: EXECUTED