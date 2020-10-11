//! account: shashank, 100
//! account: bob, 100

// We test creation of autopay, retiriving it using same and different accounts
// Finally, we also test deleting of autopay

// Test to create pledge and retrieve it
//! new-transaction
//! sender: shashank
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    AutoPay::enable_autopay();
    Transaction::assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    AutoPay::create_pledge(1, {{bob}}, 2, 5);
    let (payee, end_epoch, percentage) = AutoPay::query_pledge(Signer::address_of(sender), 1);
    Transaction::assert(payee == {{bob}}, 1);
    Transaction::assert(end_epoch == 2, 1);
    Transaction::assert(percentage == 5, 1);
    }
}
// check: EXECUTED

// Query using different account
//! new-transaction
//! sender: bob
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  fun main() {
    let (payee, end_epoch, percentage) = AutoPay::query_pledge({{shashank}}, 1);
    Transaction::assert(payee == {{bob}}, 1);
    Transaction::assert(end_epoch == 2, 1);
    Transaction::assert(percentage == 5, 1);
    }
}
// check: EXECUTED


// Test to create pledge and retrieve it
//! new-transaction
//! sender: shashank
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    AutoPay::delete_pledge(1);
    let (payee, end_epoch, percentage) = AutoPay::query_pledge(Signer::address_of(sender), 1);
    // If autopay pledge doesn't exists, it returns (0x0, 0, 0)
    Transaction::assert(payee == {{0x0}}, 1);
    Transaction::assert(end_epoch == 0, 1);
    Transaction::assert(percentage == 0, 1);
    }
}
// check: EXECUTED
