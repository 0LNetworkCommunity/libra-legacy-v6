//! account: alice, 1000000, 0, validator

// Initialize alice autopay with empty
//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  use 0x0::Vector;
  fun main() {
    AutoPay::init_status(true);
    AutoPay::init_data(Vector::empty());
  }
}
// check: EXECUTED

//! new-transaction
//! sender: alice
script {
  use 0x0::AutoPay;
  fun main() {
    AutoPay::create(true, 0, 0, 1, 0, 5, 0, 0, 0, true);
  }
}
// check: EXECUTED

// The next part is performing some query checks to make sure the payment
// exists with the account and is behaving properly


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
