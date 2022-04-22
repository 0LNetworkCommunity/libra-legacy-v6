//! account: carol, 1GAS
//! account: bob, 1GAS
//! account: alice, 1GAS

// We test creation of autopay, retiriving it using same and different accounts
// Finally, we also test deleting of autopay

// Test to create instruction and retrieve it
//! new-transaction
//! sender: carol
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(sender: signer) {
    let sender = &sender;
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    AutoPay::create_instruction(sender, 1, 0, @{{bob}}, 2, 5);
    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    assert!(type == 0u8, 1);
    assert!(payee == @{{bob}}, 1);
    assert!(end_epoch == 2, 1);
    assert!(percentage == 5, 1);
  }
}
// check: EXECUTED

// Test to create another instruction
//! new-transaction
//! sender: carol
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(sender: signer) {    
    assert!(AutoPay::is_enabled(Signer::address_of(&sender)), 0);
    AutoPay::create_instruction(&sender, 2, 0, @{{alice}}, 4, 5);
  }
}
// check: EXECUTED

// // // Test to create instruction with wrong UUID
// //! new-transaction
// //! sender: carol
// script {
//   use 0x0::AutoPay;
//   use 0x0::Transaction;
//   use 0x0::Signer;
//   fun main(sender: signer) {
//     AutoPay::enable_autopay();
//     Transaction::assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
//     AutoPay::create_instruction(2, @{{bob}}, 5, 5);
//     }
// }
// // check: EXECUTED
