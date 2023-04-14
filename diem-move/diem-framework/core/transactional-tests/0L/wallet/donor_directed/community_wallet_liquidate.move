//# init --validators Alice Bob Carol Dave


//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DonorDirected;
    use DiemFramework::DiemAccount;
    use DiemFramework::Receipts;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      DonorDirected::init_donor_directed(&sender, @Bob, @Carol, @Dave, 2);
      DonorDirected::finalize_init(&sender);
      let list = DonorDirected::get_root_registry();
      assert!(Vector::length(&list) == 1, 7357001);
      assert!(DonorDirected::is_donor_directed(@Alice), 7357002);
      assert!(Receipts::is_init(@Carol), 7357003);
      assert!(DiemAccount::is_init_cumu_tracking(@Alice), 7357004);
    }
}
// check: EXECUTED

// CAROL WILL BE A DONOR TO THE DONOR DIRECTED ACCOUNT of ALICE

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Receipts;
    use DiemFramework::Debug::print;
    
    fun main(dr: signer, sender: signer) {
      // mock more funds in Carol's account
      DiemAccount::slow_wallet_epoch_drip(&dr, 100000);

      let carols_donation = 1000;

      let cap = DiemAccount::extract_withdraw_capability(&sender);
      DiemAccount::pay_from<GAS>(&cap, @Alice, carols_donation, b"thanks", b"");
      DiemAccount::restore_withdraw_capability(cap);

      let (a, b, c) = Receipts::read_receipt(@Carol, @Alice);
      assert!(a == 0, 7357005); // timestamp is 0
      assert!(b == carols_donation, 7357006); // last payment
      assert!(c == carols_donation, 7357007); // cumulative payments

      let t = DiemAccount::get_cumulative_deposits(@Alice);
      print(&t);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DonorDirected;
    use DiemFramework::DonorDirectedGovernance;
    use DiemFramework::DiemAccount;
    use DiemFramework::Debug::print;
    
    fun main(_dr: signer, sender: signer) {
      let t = DiemAccount::get_cumulative_deposits(@Alice);
      print(&t);

      let a = DonorDirectedGovernance::check_is_donor(@Alice, @Carol);
      assert!(a, 7357009);
      // let guid = GUID::create_id(@Alice, 2);
      // print(&a);
      DonorDirected::propose_liquidation(&sender, @Alice);
      DonorDirected::vote_liquidation_tx(sender, @Alice);

      let b = DonorDirected::get_liquidation_queue();
      print(&b);

    }
}
// check: EXECUTED