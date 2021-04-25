//! account: alice, 1000000
//! account: bob, 1000000
//! account: carol, 1000000

// We test creation of autopay, retiriving it using same and different accounts
// Finally, we also test deleting of autopay

// Test to create instruction and retrieve it
//! new-transaction
//! sender: alice
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

// Test to create another instruction
//! new-transaction
//! sender: carol
script {
  use 0x1::AutoPay;
  use 0x1::Signer;
  fun main(sender: &signer) {
    assert(AutoPay::is_enabled(Signer::address_of(sender)), 0);    
    AutoPay::create_instruction(sender, 2, {{alice}}, 4, 5);
    }
}
// check: EXECUTED
