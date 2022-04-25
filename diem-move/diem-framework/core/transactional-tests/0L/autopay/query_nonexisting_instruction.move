//# init --validators Shashank Bob

// We are trying to query a instruction which doesnot exist in the network

// Create instruction and retrieve it
//# run --admin-script --signers DiemRoot Shashank
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(_dr: signer, sender: signer) {
    let sender = &sender;
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    // If autopay instruction doesn't exists, it returns (@0x0, 0, 0)
    assert!(type == 0, 1);
    assert!(payee == {{@0x0}}, 1);
    assert!(end_epoch == 0, 1);
    assert!(percentage == 0, 1);
  }
}
// check: EXECUTED
