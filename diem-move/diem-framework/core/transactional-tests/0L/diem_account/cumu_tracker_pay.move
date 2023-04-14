//# init --validators Alice Bob Carol Dave

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::Receipts;
    
    fun main(dr: signer, sender: signer) {
      
      DiemAccount::vm_migrate_cumulative_deposits(&dr, &sender, false);

      assert!(DiemAccount::is_init_cumu_tracking(@Alice), 7357001);
      let t = DiemAccount::get_cumulative_deposits(@Alice);
      assert!(t == 0, 7357002);

      // also check Carol's is properly initialized
      assert!(Receipts::is_init(@Carol), 7357003);
    }
}
// check: EXECUTED

// CAROL WILL BE A DONOR TO THE DONOR DIRECTED ACCOUNT of ALICE

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
      DiemAccount::pay_from<GAS>(&cap, @Alice, carols_donation, b"thanks", b"");
      DiemAccount::restore_withdraw_capability(cap);

      let (a, b, c) = Receipts::read_receipt(@Carol, @Alice);
      assert!(a == 0, 7357004); // timestamp is 0
      assert!(b == carols_donation, 7357005); // last payment
      assert!(c == carols_donation, 7357006); // cumulative payments

      let alice_cumu = DiemAccount::get_cumulative_deposits(@Alice);
      assert!(alice_cumu == carols_donation, 7357007);
      // print(&t);
    }
}
// check: EXECUTED
