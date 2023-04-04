//# init --parent-vasps Dave Alice Sally Bob CommunityA
// Dave, Sally:     validators with 10M GAS
// Alice, Bob:  non-validators with  1M GAS

// We test processing of autopay at differnt epochs and balance transfers
// Finally, we also check the end_epoch functionality of autopay




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

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::AutoPay;
  use Std::Signer;

  fun main(_dr: signer, sender: signer) {
    let sender = &sender;    
    AutoPay::enable_autopay(sender);
    assert!(AutoPay::is_enabled(Signer::address_of(sender)), 7357001);
    AutoPay::create_instruction(sender, 1, 0, @CommunityA, 2, 500);
    let (type, payee, end_epoch, percentage) = AutoPay::query_instruction(
      Signer::address_of(sender), 1
    );
    assert!(type == 0u8, 7357002);
    assert!(payee == @CommunityA, 7357003);
    assert!(end_epoch == 2, 7357004);
    assert!(percentage == 500, 7357005);
  }
}
// check: EXECUTED

// Processing AutoPay to see if payments are done
//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::AutoPay;
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(dr:signer, _account: signer) {
    let alice_balance = DiemAccount::balance<GAS>(@Alice);
    let bob_balance = DiemAccount::balance<GAS>(@CommunityA);
    assert!(alice_balance == 1000000, 7357007);

    AutoPay::process_autopay(&dr);
    
    let alice_balance_after = DiemAccount::balance<GAS>(@Alice);
    assert!(alice_balance_after < alice_balance, 7357008);
    
    let transferred = alice_balance - alice_balance_after;    
    let bob_received = DiemAccount::balance<GAS>(@CommunityA) - bob_balance;    
    assert!(transferred==bob_received, 7357009)
  }
}
// check: EXECUTED