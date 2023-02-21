//# init --validators Alice Bob Carol

// NOTE: bob and carol are initialized as validators because --parent-vasp does not initialize balances completely.

// Scenario: Alice is a validators. There are two community wallets, Bob and Carol. The excess network fees from the auction, will be burnt according to Alice's preferences.


//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);

      //starting tracker at 0;
      DiemAccount::init_cumulative_deposits(&sender, 0);

      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::DiemAccount;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);

      //starting tracker at 0;
      DiemAccount::init_cumulative_deposits(&sender, 0);

      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 2, 7357002);

    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Burn;
    use DiemFramework::Mock;
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    // use DiemFramework::Debug::print;

    fun main(vm: signer, sender: signer) {
      // alice burns to community
      Burn::set_send_community(&sender, true);

      Mock::mock_network_fees(&vm, 10000);

      let bal_alice_old = DiemAccount::balance<GAS>(@Alice);
      // print(&bal_alice_old);
      // Mock the community wallet index
      // send to community wallet Bob
      DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Bob, 10000, x"", x"", &vm);
      // send to community wallet Carol
      DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Carol, 60000, x"", x"", &vm);
      let bal_alice_new = DiemAccount::balance<GAS>(@Alice);
      assert!(bal_alice_new < bal_alice_old, 7357003);

      // end of epoch, recalculate the index
      Burn::reset_ratios(&vm);
    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::Burn;
    use DiemFramework::Receipts;
    use DiemFramework::DiemSystem;
    use Std::Vector;
    use DiemFramework::Debug::print;

    fun main(dr: signer, _sender: signer) {
      let all_vals = DiemSystem::get_val_set_addr();
      let auction_entry_fee_single = 7000;

      // check if this is calculating correctly before applying.
      let (vals, total) = Burn::calc_community_recycling(*&all_vals, auction_entry_fee_single);
      assert!(Vector::length(&vals) == 1, 7357003);
      assert!(total == auction_entry_fee_single, 7357004);

      Burn::process_network_burn(&dr, all_vals, auction_entry_fee_single);

      let (_, last_payment, cumu) = Receipts::read_receipt(@Alice, @Bob);
      let first_donation = 10000;

      print(&last_payment);
      print(&cumu);
      assert!(last_payment == 999, 7357005 );
      assert!((cumu - first_donation) == last_payment, 7357006);
      let (_, last_payment, cumu) = Receipts::read_receipt(@Alice, @Carol);

      let first_donation = 60000;
      print(&last_payment);
      print(&cumu);

      assert!(last_payment == 5999, 7357007);
      assert!((cumu - first_donation) == last_payment, 7357008);
    }
}
// check: EXECUTED
