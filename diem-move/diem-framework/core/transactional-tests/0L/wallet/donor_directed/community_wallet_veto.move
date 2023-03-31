//# init --validators Alice Bob Carol Dave


//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      DonorDirected::init_donor_directed(&sender, @Bob, @Carol, @Dave, 2);
      DonorDirected::finalize_init(&sender);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 1, 7357001);

      assert!(DonorDirected::is_donor_directed(@Alice), 7357002);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::DonorDirected;
    
    fun main(_dr: signer, sender: signer) {
      let uid = DonorDirected::propose_payment(&sender, @Alice, @Bob, 100, b"thanks bob");
      let (found, idx, status_enum, completed) = DonorDirected::get_multisig_proposal_state(@Alice, &uid);

      assert!(found, 7357004);
      assert!(idx == 0, 7357005);
      assert!(status_enum == 1, 7357006);
      assert!(!completed, 7357007);

      // it is not yet scheduled, it's still only a proposal by a donor directed wallet.
      assert!(!DonorDirected::is_scheduled(@Alice, &uid), 7357003);
    }
}
// check: EXECUTED



//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DonorDirected;
    use Std::Vector;
    
    fun main(_dr: signer, sender: signer) {
      let uid = DonorDirected::propose_payment(&sender, @Alice, @Bob, 100, b"thanks bob");
      let (found, idx, status_enum, completed) = DonorDirected::get_multisig_proposal_state(@Alice, &uid);

      assert!(found, 7357004);
      assert!(idx == 0, 7357005);
      assert!(status_enum == 1, 7357006);
      assert!(completed, 7357007);

      // Now it's scheduled since we got over the threshold
      assert!(DonorDirected::is_scheduled(@Alice, &uid), 7357003);

      // the default timed payment is 3 epochs, we are in epoch 1
      let list = DonorDirected::find_by_deadline(@Alice, 4);
      assert!(Vector::contains(&list, &uid), 7357008);
    }
}
// check: EXECUTED


// LETS MAKE CAROL A DONOR


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;

    fun main(dr: signer, _sender: signer) {
      DiemAccount::slow_wallet_epoch_drip(&dr, 100000);

    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Receipts;
    use DiemFramework::Debug::print;
    
    fun main(_dr: signer, sender: signer) {
      // Receipts::init(&sender);
      let a = Receipts::is_init(@Carol);
      print(&a);

      let b = DiemAccount::is_init_cumu_tracking(@Alice);
      print(&b);

      let cap = DiemAccount::extract_withdraw_capability(&sender);
      DiemAccount::pay_from<GAS>(&cap, @Alice, 1000, b"thanks alice", b"");
      DiemAccount::restore_withdraw_capability(cap);

      let (a, b, c) = Receipts::read_receipt(@Carol, @Alice);
      print(&a);
      print(&b);
      print(&c);

    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DonorDirected;
    use DiemFramework::DonorDirectedGovernance;
    use Std::Signer;
    use DiemFramework::Debug::print;
    
    fun main(_dr: signer, sender: signer) {
      let a = DonorDirectedGovernance::check_is_donor(@Alice, Signer::address_of(&sender));
      print(&a);
      DonorDirected::propose_veto(&sender, @Alice, 2);
    }
}
// check: EXECUTED