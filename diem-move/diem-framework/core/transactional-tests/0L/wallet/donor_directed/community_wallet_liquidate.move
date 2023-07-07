//# init --validators CommunityScam Bob Carol Dave

//# run --admin-script --signers DiemRoot CommunityScam
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
      assert!(DonorDirected::is_donor_directed(@CommunityScam), 7357002);
      assert!(Receipts::is_init(@Carol), 7357003);
      assert!(DiemAccount::is_init_cumu_tracking(@CommunityScam), 7357004);
    }
}
// check: EXECUTED

// CAROL WILL BE A DONOR TO THE DONOR DIRECTED ACCOUNT of CommunityScam

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Receipts;
    
    fun main(dr: signer, sender: signer) {
      // mock more funds in Carol's account
      DiemAccount::slow_wallet_epoch_drip(&dr, 100000);

      let carols_donation = 1000;

      let cap = DiemAccount::extract_withdraw_capability(&sender);
      DiemAccount::pay_from<GAS>(&cap, @CommunityScam, carols_donation, b"thanks", b"");
      DiemAccount::restore_withdraw_capability(cap);

      let (a, b, c) = Receipts::read_receipt(@Carol, @CommunityScam);
      assert!(a == 0, 7357005); // timestamp is 0
      assert!(b == carols_donation, 7357006); // last payment
      assert!(c == carols_donation, 7357007); // cumulative payments
    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Receipts;
    // use DiemFramework::Debug::print;
    
    fun main(_dr: signer, sender: signer) {
      let dave_donation = 200;
      let cap = DiemAccount::extract_withdraw_capability(&sender);
      DiemAccount::pay_from<GAS>(&cap, @CommunityScam, dave_donation, b"thanks", b"");
      DiemAccount::restore_withdraw_capability(cap);

      let (a, b, c) = Receipts::read_receipt(@Dave, @CommunityScam);
      assert!(a == 0, 7357005); // timestamp is 0
      assert!(b == dave_donation, 7357006); // last payment
      assert!(c == dave_donation, 7357007); // cumulative payments

    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DonorDirected;
    use DiemFramework::DonorDirectedGovernance;
    // use DiemFramework::EpochBoundary;
    // use DiemFramework::Debug::print;
    
    fun main(_dr: signer, sender: signer) {
      // let t = DiemAccount::get_cumulative_deposits(@CommunityScam);

      let a = DonorDirectedGovernance::check_is_donor(@CommunityScam, @Carol);
      assert!(a, 7357009);
      // let guid = GUID::create_id(@CommunityScam, 2);
      // print(&a);
      DonorDirected::propose_liquidation(&sender, @CommunityScam);
      DonorDirected::vote_liquidation_tx(sender, @CommunityScam);


    }
}
// check: EXECUTED


// NOTE: THERE IS A COOL OFF PERIOD OF 1 EPOCH with a provisional pass


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Bob --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::DonorDirected;

    use Std::Vector;
    
    fun main(_dr: signer, sender: signer) {
      // new epoch, we need a second epoch to trigger
      DonorDirected::vote_liquidation_tx(sender, @CommunityScam);

      let b = DonorDirected::get_liquidation_queue();
      
      assert!(Vector::length(&b) == 1, 7357010);

      // print(&b);
    }
}
// check: EXECUTED

// new epoch should now liquidate the account

//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Bob --time 131000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::DonorDirected;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;

    // use DiemFramework::Debug::print;
    use Std::Vector;
    
    fun main(_dr: signer, _sender: signer) {
      let b = DonorDirected::get_liquidation_queue();
      
      assert!(Vector::is_empty(&b), 7357011);
      
      let original_balance = 10000000;
      let superman_3 = 2; // missing cents from fixed point operations
      // NOTE: we are not liquidating all the balance. If there was previous balance before donations were being tracked, that balance is still there
      // we only liquidate the tracked donor balances.
      assert!(DiemAccount::balance<GAS>(@CommunityScam) == original_balance + superman_3, 7357012);
    }
}
// check: EXECUTED