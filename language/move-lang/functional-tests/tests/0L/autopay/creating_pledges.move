//! account: shashank, 1000000
//! account: bob, 1000000
//! account: alice, 1000000

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

// Test to create another pledge
//! new-transaction
//! sender: shashank
script {
  use 0x0::AutoPay;
  use 0x0::Transaction;
  use 0x0::Signer;
  fun main(sender: &signer) {
    Transaction::assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    // AutoPay::create_pledge(2, {{alice}}, 4, 5);
    }
}
// check: EXECUTED

// // // Test to create pledge with wrong UUID
// //! new-transaction
// //! sender: shashank
// script {
//   use 0x0::AutoPay;
//   use 0x0::Transaction;
//   use 0x0::Signer;
//   fun main(sender: &signer) {
//     AutoPay::enable_autopay();
//     Transaction::assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
//     AutoPay::create_pledge(2, {{bob}}, 5, 5);
//     }
// }
// // check: EXECUTED
