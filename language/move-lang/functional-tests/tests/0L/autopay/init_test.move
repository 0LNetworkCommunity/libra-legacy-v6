//! account: alice, 1000000
//! account: bob, 1000000

//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    AutoPay::verify_initialized();
    AutoPay::init_status(true);
    let payments = AutoPay::make_dummy_payment_vec();
    AutoPay::init_data(payments);
    Transaction::assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    Transaction::assert(AutoPay::num_payments(Signer::address_of(sender)) == 1, 1);
  }
}
// check: EXECUTED

//! new-transaction
//! sender: bob
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    AutoPay::init_status(false);
    Transaction::assert(!AutoPay::is_enabled(Signer::address_of(sender)), 2);
  }
}
// check: EXECUTED

// Should abort because bob doesn't have a data struct to query
//! new-transaction
//! sender: bob
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    Transaction::assert(!AutoPay::is_enabled(Signer::address_of(sender)), 0);
    // should abort since can't borrow struct which doesn't exist
    Transaction::assert(AutoPay::num_payments(Signer::address_of(sender)) == 1, 1);
  }
}
// check: Failure
// check: MISSING_DATA