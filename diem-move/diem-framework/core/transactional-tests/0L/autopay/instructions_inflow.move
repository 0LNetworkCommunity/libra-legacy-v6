//# init --parent-vasps Bob Alice Dave CommunityA CommunityB CommunityC
// Bob, Dave:       validators with 10M GAS
// Alice, CommunityA: non-validators with  1M GAS

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

// test runs various autopay instruction types to ensure they are being executed as expected

//# run --admin-script --signers DiemRoot CommunityB
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sponsor: signer) {
      DonorDirected::init_donor_directed(&sponsor, @Alice, @Bob, @Dave, 2);
      DonorDirected::finalize_init(&sponsor);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 2, 7357003);
      assert!(DiemAccount::is_init_cumu_tracking(@CommunityA), 7357004);

    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot CommunityC
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sponsor: signer) {
      DonorDirected::init_donor_directed(&sponsor, @Alice, @Bob, @Dave, 2);
      DonorDirected::finalize_init(&sponsor);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 3, 7357005);
      assert!(DiemAccount::is_init_cumu_tracking(@CommunityA), 7357006);

    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::AutoPay;
  use Std::Signer;
  fun main(_dr: signer, sender: signer) {
    let sender = &sender;
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 0);
    
    AutoPay::create_instruction(sender, 1, 1, @CommunityA, 2, 500); //5%
    AutoPay::create_instruction(sender, 2, 1, @CommunityC, 2, 1000);  //10%

    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    assert!(type == 1, 1);
    assert!(payee == @CommunityA, 1);
    assert!(end_epoch == 2, 1);
    assert!(percentage == 500, 1);

    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 2
    );
    assert!(type == 1, 2);
    assert!(payee == @CommunityC, 2);
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
        @VMReserved,
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
    let ending_balance = DiemAccount::balance<GAS>(@CommunityA);
    assert!(ending_balance == 1000499, 7357005);

    let ending_balance = DiemAccount::balance<GAS>(@CommunityC);
    assert!(ending_balance == 1000999, 7357006);    
  }
}