//# init --validators Alice Bob Dave CommunityA CommunityB

// Check that the burn preferences for each user are being registered
// and check that the burn ratio is being calculated correctly.


//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Burn;

    fun main(_dr: signer, sender: signer) {
      // alice chooses a pure burn for all burns.
      Burn::set_send_community(&sender, false);
    }
}
// check: EXECUTED

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
      assert!(DiemAccount::is_init_cumu_tracking(@CommunityB), 7357004);

    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Burn;
  use DiemFramework::Diem;
  // use Std::FixedPoint32;
  // use DiemFramework::Debug::print;

  fun main(vm: signer, _:signer) {
    // we assume the ratios are calculated correctly see burn_ratios.move
    let total_supply_before = Diem::market_cap<GAS>();
    // // print(&total_supply_before);

    let bal_A_before = DiemAccount::balance<GAS>(@CommunityA);
    let bal_B_before = DiemAccount::balance<GAS>(@CommunityB);

    let c = DiemAccount::vm_withdraw<GAS>(&vm, @Alice, 1000000);
    Burn::burn_or_recycle_user_fees(&vm, @Alice, c);

    let bal_alice = DiemAccount::balance<GAS>(@Alice);
    // print(&bal_alice);
    assert!(bal_alice == 9000000, 7357007); // rounding issues
    
    // unchanged balance
    let bal_a = DiemAccount::balance<GAS>(@CommunityA);
    // // print(&bal_bob);
    assert!(bal_a == bal_A_before, 7357008);

    // unchanged balance
    let bal_b = DiemAccount::balance<GAS>(@CommunityB);
    assert!(bal_b == bal_B_before, 7357009);

    let total_supply_after = Diem::market_cap<GAS>();

    assert!(total_supply_after < total_supply_before, 7357010);

  }
}
// check: EXECUTED


// //# run --admin-script --signers DiemRoot Alice
// script {
//   use DiemFramework::Burn;

//     fun main(_dr: signer, sender: signer) {
//     Burn::set_send_community(&sender, true);
//   }
// }
// //////// SETS community send

// //# run --admin-script --signers DiemRoot DiemRoot
// script {
//   use DiemFramework::DiemAccount;
//   use DiemFramework::GAS::GAS;
//   use DiemFramework::Burn;
//   // use DiemFramework::Debug::print;

//   fun main(vm: signer, _:signer) {
//     let bal_alice = DiemAccount::balance<GAS>(@Alice);
//     // print(&bal_alice);

//     let bal_bob_old = DiemAccount::balance<GAS>(@Bob);
//     // print(&bal_bob_old);
//     let bal_carol_old = DiemAccount::balance<GAS>(@Carol);

//     // this time alice changed burn settings, and is resending to community.
//     Burn::epoch_start_burn(&vm, @Alice, 100000);
    

//     let bal_alice = DiemAccount::balance<GAS>(@Alice);
//     // print(&bal_alice);
//     assert!(bal_alice == 9100000, 7357010); // rounding issues

//     // balances are greater than before.
//     let bal_bob = DiemAccount::balance<GAS>(@Bob);
//     assert!(bal_bob > bal_bob_old, 7357011);

//     // balances are greater than before.
//     let bal_carol = DiemAccount::balance<GAS>(@Carol);
//     assert!(bal_carol > bal_carol_old, 7357012);
//   }
// }
// // check: EXECUTED