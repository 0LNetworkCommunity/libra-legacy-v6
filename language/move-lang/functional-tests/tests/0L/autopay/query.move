//! account: alice, 1000000, 0, validator

// Initialize alice autopay
//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  fun main() {
    AutoPay::init_status(true);
    AutoPay::init_data(AutoPay::make_dummy_payment_vec());
  }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  use 0x0::Signer;
  use 0x0::Transaction;
  fun main(sender: &signer) {
    let (past, future) = AutoPay::query(Signer::address_of(sender), 0);
    Transaction::assert(past == 0, 1);
    Transaction::assert(future == 6, 2);
  }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 2

//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  use 0x0::Signer;
  use 0x0::Transaction;
  fun main(sender: &signer) {
    let (past, future) = AutoPay::query(Signer::address_of(sender), 0);
    Transaction::assert(past == 1, 3);
    Transaction::assert(future == 5, 4);
  }
}
// check: EXECUTED
