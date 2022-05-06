//# init --validators Alice Bob Carol
    // todo: Make them non-validators
//// Old syntax for reference, delete it after fixing this test
//! account: alice, 2000000GAS, 0 
//! account: bob,   1000000GAS, 0, validator
//! account: carol, 1000000GAS, 0

// test runs various autopay instruction types to ensure they are being executed as expected

//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::Wallet;
  use Std::Vector;

  fun main(_dr: signer, sender: signer) {
    Wallet::set_comm(&sender);
    let list = Wallet::get_comm_list();
    assert!(Vector::length(&list) == 1, 7357001);
  }
}
// check: EXECUTED

// alice commits to paying carol 200 GAS per epoch
//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(_dr: signer, sender: signer) {
    let sender = &sender;
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    AutoPay::create_instruction(sender, 1, 2, @Carol, 2, 200);

    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    assert!(type == 2, 1);
    assert!(payee == @Carol, 1);
    assert!(end_epoch == 2, 1);
    assert!(percentage == 200, 1);
  }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs /////
///// i.e. 1 second after 1/2 epoch   /////
///////////////////////////////////////////////////
//# block --proposer Bob --time 31000000 --round 23

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  fun main() {
    let ending_balance = DiemAccount::balance<GAS>(@Alice);
    assert!(ending_balance == 9999800, 7357002);
  }
}
// check: EXECUTED

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs /////
///// i.e. 1 second after 1/2 epoch   /////
///////////////////////////////////////////////////
//# block --proposer Bob --time 61000000 --round 65

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs /////
///// i.e. 1 second after 1/2 epoch   /////
///////////////////////////////////////////////////
//# block --proposer Bob --time 92000000 --round 66

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs /////
///// i.e. 1 second after 1/2 epoch   /////
///////////////////////////////////////////////////
//# block --proposer Bob --time 93000000 --round 67

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  fun main() {
    // alice will have paid 5% on the 10000 she received last epoch
    let ending_balance = DiemAccount::balance<GAS>(@Alice);
    assert!(ending_balance == 9999600, 7357003);

    // check balance of recipients
    let ending_balance = DiemAccount::balance<GAS>(@Carol);
    assert!(ending_balance == 10000400, 7357004);
  }
}
// check: EXECUTED
