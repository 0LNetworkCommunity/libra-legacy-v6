//# init --validators Community Bob Carol Dave

//# run --admin-script --signers DiemRoot Community
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::Receipts;
    
    fun main(dr: signer, sender: signer) {
      
      DiemAccount::vm_migrate_cumulative_deposits(&dr, &sender, false);

      assert!(DiemAccount::is_init_cumu_tracking(@Community), 7357001);
      let t = DiemAccount::get_cumulative_deposits(@Community);
      assert!(t == 0, 7357002);

      // also check Carol's is properly initialized
      assert!(Receipts::is_init(@Carol), 7357003);
    }
}
// check: EXECUTED

// CAROL WILL BE A DONOR TO THE DONOR DIRECTED ACCOUNT of Community

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Receipts;
    // use DiemFramework::Debug::print;
    
    fun main(dr: signer, sender: signer) {
      // mock more funds in Carol's account
      DiemAccount::slow_wallet_epoch_drip(&dr, 100000);

      let carols_donation = 1000;

      let cap = DiemAccount::extract_withdraw_capability(&sender);
      DiemAccount::pay_from<GAS>(&cap, @Community, carols_donation, b"thanks", b"");
      DiemAccount::restore_withdraw_capability(cap);

      let (a, b, c) = Receipts::read_receipt(@Carol, @Community);
      assert!(a == 0, 7357004); // timestamp is 0
      assert!(b == carols_donation, 7357005); // last payment
      assert!(c == carols_donation, 7357006); // cumulative payments

      let community_cumu = DiemAccount::get_cumulative_deposits(@Community);
      assert!(community_cumu == carols_donation, 7357007);
      // print(&t);
    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Receipts;
    use Std::Vector;
    use Std::FixedPoint32;
    // use DiemFramework::Debug::print;
    
    fun main(_dr: signer, sender: signer) {
      let dave_donation = 200;
      let cap = DiemAccount::extract_withdraw_capability(&sender);
      DiemAccount::pay_from<GAS>(&cap, @Community, dave_donation, b"thanks", b"");
      DiemAccount::restore_withdraw_capability(cap);

      let (a, b, c) = Receipts::read_receipt(@Dave, @Community);
      assert!(a == 0, 7357005); // timestamp is 0
      assert!(b == dave_donation, 7357006); // last payment
      assert!(c == dave_donation, 7357007); // cumulative payments

      let carols_donation = 1000;

      let community_cumu = DiemAccount::get_cumulative_deposits(@Community);
      assert!(community_cumu == (carols_donation + dave_donation), 7357008);

      let (a, b, c) = DiemAccount::get_pro_rata_cumu_deposits(@Community);

      assert!(Vector::length(&a) == 2, 7357009);
      assert!(Vector::length(&b) == 2, 7357010);
      assert!(Vector::length(&c) == 2, 7357011);

      assert!(Vector::borrow(&a, 0) == &@Carol, 7357012);

      let carol_ratio = FixedPoint32::create_from_rational(carols_donation, community_cumu);
      assert!(Vector::borrow(&b, 0) == &carol_ratio, 7357013);

      let dave_ratio = FixedPoint32::create_from_rational(dave_donation, community_cumu);
      assert!(Vector::borrow(&b, 1) == &dave_ratio, 7357014);
    }
}
// check: EXECUTED
