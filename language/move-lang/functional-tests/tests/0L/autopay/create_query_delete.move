//! account: shashank, 100
//! account: bob, 100

// We test creation of autopay, retiriving it using same and different accounts
// Finally, we also test deleting of autopay

// Test to create instruction and retrieve it
//! new-transaction
//! sender: shashank
script {
  use 0x1::AutoPay;
  use 0x1::Signer;
  fun main(sender: &signer) {
    AutoPay::enable_autopay(sender);
    assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    AutoPay::create_instruction(sender, 1, {{bob}}, 2, 5);
    let (payee, end_epoch, percentage) = AutoPay::query_instruction(Signer::address_of(sender), 1);
    assert(payee == {{bob}}, 1);
    assert(end_epoch == 2, 1);
    assert(percentage == 5, 1);
    }
}
// check: EXECUTED

// Query using different account
//! new-transaction
//! sender: bob
script {
  use 0x1::AutoPay;
  fun main() {
    let (payee, end_epoch, percentage) = AutoPay::query_instruction({{shashank}}, 1);
    assert(payee == {{bob}}, 1);
    assert(end_epoch == 2, 1);
    assert(percentage == 5, 1);
    }
}
// check: EXECUTED


// Test to create instruction and retrieve it
//! new-transaction
//! sender: shashank
script {
  use 0x1::AutoPay;
  use 0x1::Signer;
  fun main(sender: &signer) {
    AutoPay::delete_instruction(sender, 1);
    let (payee, end_epoch, percentage) = AutoPay::query_instruction(Signer::address_of(sender), 1);
    // If autopay instruction doesn't exists, it returns (0x0, 0, 0)
    assert(payee == {{0x0}}, 1);
    assert(end_epoch == 0, 1);
    assert(percentage == 0, 1);
    }
}
// check: EXECUTED
