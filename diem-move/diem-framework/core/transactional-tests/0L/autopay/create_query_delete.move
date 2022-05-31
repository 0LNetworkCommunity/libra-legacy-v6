//# init --parent-vasps Carol Alice Jim Bob
// Carol, Jim:     validators with 10M GAS
// Alice, Bob: non-validators with  1M GAS

// We test creation of autopay, retiriving it using same and different accounts
// Finally, we also test deleting of autopay

// Test to create instruction and retrieve it
//# run --admin-script --signers DiemRoot Alice
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
    assert!(type == 0, 1);
    assert!(payee == @Bob, 1);
    assert!(end_epoch == 2, 1);
    assert!(percentage == 5, 1);
  }
}
// check: EXECUTED

// Query using different account
//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::AutoPay;

  fun main() {
    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(@Alice, 1);
    assert!(type == 0, 1);
    assert!(payee == @Bob, 1);
    assert!(end_epoch == 2, 1);
    assert!(percentage == 5, 1);
  }
}
// check: EXECUTED


// Test to create instruction and retrieve it
//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  
  fun main(_dr: signer, sender: signer) {
    let sender = &sender;
    AutoPay::delete_instruction(sender, 1);
    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    // If autopay instruction doesn't exists, it returns (@0x0, 0, 0)
    assert!(type == 0u8, 1);
    assert!(payee == @0x0, 1);
    assert!(end_epoch == 0, 1);
    assert!(percentage == 0, 1);
  }
}
// check: EXECUTED
