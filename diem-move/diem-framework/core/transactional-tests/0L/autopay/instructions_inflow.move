//# init --parent-vasps Bob Alice Sally Carol X Eve
// Bob, Sally, X:         validators with 10M GAS
// Alice, Carol, Eve: non-validators with  1M GAS

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

//# run --admin-script --signers DiemRoot Eve
script {
  use DiemFramework::Wallet;
  use Std::Vector;

  fun main(_dr: signer, sender: signer) {
    Wallet::set_comm(&sender);
    let list = Wallet::get_comm_list();
    assert!(Vector::length(&list) == 2, 7357007);
  }
}

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(_dr: signer, sender: signer) {
    let sender = &sender;
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    AutoPay::create_instruction(sender, 1, 1, @Carol, 2, 500); //5%
    AutoPay::create_instruction(sender, 2, 1, @Eve, 2, 1000);  //10%

    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    assert!(type == 1, 1);
    assert!(payee == @Carol, 1);
    assert!(end_epoch == 2, 1);
    assert!(percentage == 500, 1);

    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 2
    );
    assert!(type == 1, 2);
    assert!(payee == @Eve, 2);
    assert!(end_epoch == 2, 2);
    assert!(percentage == 1000, 2);    
  }
}

///////////////////////////////////////////////////
///// Trigger Autopay Tick at 31 secs /////
///// i.e. 1 second after 1/2 epoch   /////
///////////////////////////////////////////////////
//# block --proposer Bob --time 31000000 --round 23

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Diem;
  fun main(vm: signer, _account: signer) {
    // alice didn't receive any funds, so no change in balance, so no payment sent
    let ending_balance = DiemAccount::balance<GAS>(@Alice);
    assert!(ending_balance == 1000000, 7357002);

    // add funds to alice account for next tick
    let coin = Diem::mint<GAS>(&vm, 10000);
    assert!(Diem::value<GAS>(&coin) == 10000, 1);
    DiemAccount::vm_deposit_with_metadata<GAS>(
        &vm,
        @Alice,
        coin,
        x"", x""
    );

    let ending_balance = DiemAccount::balance<GAS>(@Alice);
    assert!(ending_balance == 1010000, 7357003);
  }
}

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
    // alice will have paid 15% on the 10000 she received last epoch
    let ending_balance = DiemAccount::balance<GAS>(@Alice);
    assert!(ending_balance == 1008502, 7357004);

    // check balance of recipients
    let ending_balance = DiemAccount::balance<GAS>(@Carol);
    assert!(ending_balance == 1000499, 7357005);

    let ending_balance = DiemAccount::balance<GAS>(@Eve);
    assert!(ending_balance == 1000999, 7357006);    
  }
}