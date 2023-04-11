//# init --parent-vasps Bob Alice Dave CommunityA
// Bob, Dave:       validators with 10M GAS
// Alice, Carol: non-validators with  1M GAS

// test runs various autopay instruction types to ensure they are being executed as expected

//# run --admin-script --signers DiemRoot CommunityA
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sponsor: signer) {
      DonorDirected::init_donor_directed(&sponsor, @Alice, @Bob, @Dave, 2);
      DonorDirected::finalize_init(&sponsor);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 1, 7357001);
      assert!(DiemAccount::is_init_cumu_tracking(@CommunityA), 7357002);

    }
}
// check: EXECUTED

// Alice commits to paying carol 500 GAS at the next tick

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(_dr: signer, sender: signer) {
    let sender = &sender;
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    // note: end epoch does not matter here as long as it is after the next epoch
    AutoPay::create_instruction(sender, 1, 3, @CommunityA, 200, 500);

    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
        Signer::address_of(sender), 1
    );
    assert!(type == 3, 1);
    assert!(payee == @CommunityA, 1);
    assert!(end_epoch == 200, 1);
    assert!(percentage == 500, 1);
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
  use DiemFramework::AutoPay;
  fun main() {
    let ending_balance = DiemAccount::balance<GAS>(@Alice);
    assert!(ending_balance == 999500, 7357002);
    
    //Confirm the one-shot instruction was deleted
    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(@Alice, 1);
    assert!(type == 0, 1);
    assert!(payee == @0x0, 1);
    assert!(end_epoch == 0, 1);
    assert!(percentage == 0, 1);
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
    // no change, one-shot instruction is finished
    let ending_balance = DiemAccount::balance<GAS>(@Alice);
    assert!(ending_balance == 999500, 7357003);

    // check balance of recipients
    let ending_balance = DiemAccount::balance<GAS>(@CommunityA);
    assert!(ending_balance == 1000500, 7357004);
  }
}
// check: EXECUTED
