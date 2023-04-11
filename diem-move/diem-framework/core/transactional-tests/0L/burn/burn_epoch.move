//# init --validators Alice Bob Dave CommunityA CommunityB


// Alice is a Validator
// CommunityA is a community wallet.
// We are checking that by default, CommunityA does not receive any funds from Alice's burn, because she has not opted to recycle.
// Tests that Alice burns the cost-to-exist on every epoch, 
// (is NOT sending to community index)

//////// SETS community send, recycles burns.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Burn;
  use DiemFramework::Diem;
  use DiemFramework::GAS::GAS;
  
    fun main(_dr: signer, sender: signer) {
      assert!(Diem::market_cap<GAS>() == 77500000, 7357000);
      // Not recycling burns
      Burn::set_send_community(&sender, false);
    }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::Mock;
    use DiemFramework::DiemAccount;
    use DiemFramework::TransactionFee;
    use DiemFramework::GAS::GAS;


    fun main(vm: signer, _: signer) {
        // simulate alice making a fee
        let c = DiemAccount::vm_withdraw<GAS>(&vm, @Alice, 2000000);
        TransactionFee::pay_fee_and_track(@Alice, c);

        let start_height = 0;
        let end_height = 100;
        Mock::mock_case_1(&vm, @Alice, start_height, end_height);
    }
}




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
      // DiemAccount::vm_migrate_cumulative_deposits(&dr, &sponsor, true);
      assert!(DiemAccount::is_init_cumu_tracking(@CommunityA), 7357002);

    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  // use DiemFramework::Debug::print;

  fun main(vm: signer, _account: signer) {
    // let bal = DiemAccount::balance<GAS>(@Alice);
    // print(&bal);
    

    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @CommunityA, 1000000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@Alice);
    // print(&bal);
    assert!(bal == 7000000, 7357003);
  }
}

////////////////////////////////////////////
// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

//// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
////////////////////////////////////////////


//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Diem;
  use DiemFramework::Burn;
  use Std::Vector;

  fun main() {

    let (b, r) = Burn::get_lifetime_tracker();
    assert!(b == 1000000, 7357004);
    assert!(r == 0, 7357005);

    let (addr, deps , ratios) = Burn::get_ratios();
    assert!(Vector::length(&addr) == 1, 7357006);
    assert!(Vector::length(&deps) == 1, 7357007);
    assert!(Vector::length(&ratios) == 1, 7357008);

    let new_cap = Diem::market_cap<GAS>();
    // no change to market cap

    // alice balance should increase because of subsidy
    let alice_old_balance = 7000000;
    let alice_new = DiemAccount::balance<GAS>(@Alice);

    assert!(alice_new > alice_old_balance, 7357009);

    let bal = DiemAccount::balance<GAS>(@CommunityA);

    // no change in community wallet balance
    let old_bal_comm_a = 11000000;
    assert!(bal == old_bal_comm_a, 7357010);

    let cap_at_start = 77500000;

    // supply of coins should be less
    assert!(new_cap < cap_at_start, 7357011);

  }
}