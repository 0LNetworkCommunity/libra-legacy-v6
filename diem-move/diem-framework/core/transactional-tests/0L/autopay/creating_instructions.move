//# init --validators Alice Bob Carol

// We test creation of autopay, retiriving it using same and different accounts
// Finally, we also test deleting of autopay

// Test to create instruction and retrieve it
//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(_dr: signer, sender: signer) {
    let sender = &sender;
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    AutoPay::create_instruction(sender, 1, 0, @Bob, 2, 5);
    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    assert!(type == 0u8, 1);
    assert!(payee == @Bob, 1);
    assert!(end_epoch == 2, 1);
    assert!(percentage == 5, 1);
  }
}
// check: EXECUTED

// Test to create another instruction
//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(_dr: signer, sender: signer) {
    assert!(AutoPay::is_enabled(Signer::address_of(&sender)), 0);
    AutoPay::create_instruction(&sender, 2, 0, @Alice, 4, 5);
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
//     AutoPay::create_instruction(2, @Bob, 5, 5);
//     }
// }
// // check: EXECUTED
