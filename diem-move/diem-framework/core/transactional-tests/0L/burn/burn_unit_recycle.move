//# init --validators Alice Bob Dave CommunityA CommunityB

// Check that the burn preferences for each user are being registered
// and check that the burn ratio is being calculated correctly.



//////// SETS community send, recycles burns.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Burn;


    fun main(_dr: signer, sender: signer) {
    Burn::set_send_community(&sender, true);
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
  use Std::Vector;
  use Std::FixedPoint32;


  fun main(vm: signer, _:signer) {
    // send to community wallet CommunityA
    DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @CommunityA, 100000, x"", x"", &vm);
    // send to community wallet CommunityB
    DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @CommunityB, 900000, x"", x"", &vm);

    Burn::reset_ratios(&vm);
    let (addr, deps , ratios) = Burn::get_ratios();
    assert!(Vector::length(&addr) == 2, 7357003);
    assert!(Vector::length(&deps) == 2, 7357004);
    assert!(Vector::length(&ratios) == 2, 7357005);

    let deposits_A_indexed = *Vector::borrow<u64>(&deps, 0);
    // print(&deposits_A_indexed);
    assert!(deposits_A_indexed == 100500, 7357006);
    let deposits_B_indexed = *Vector::borrow<u64>(&deps, 1);
    // print(&deposits_B_indexed);
    assert!(deposits_B_indexed == 904500, 7357007);

    let a_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 0);
    let pct_a = FixedPoint32::multiply_u64(100, a_mult);
    // print(&pct_a);
    // ratio for communityA
    assert!(pct_a == 9, 7357008); // todo

    let b_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
    let pct_b = FixedPoint32::multiply_u64(100, b_mult);
    // print(&pct_b);
    // ratio for communityB
    assert!(pct_b == 89, 7357009);

  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Burn;
  use DiemFramework::Diem;
  // use DiemFramework::Debug::print;

  fun main(vm: signer, _:signer) {
    // we assume the ratios are calculated correctly see burn_ratios.move
    let total_supply_before = Diem::market_cap<GAS>();

    let bal_A_before = DiemAccount::balance<GAS>(@CommunityA);
    let bal_B_before = DiemAccount::balance<GAS>(@CommunityB);

    // make sure the ratios for burns get updated
    Burn::reset_ratios(&vm);
    // up to here Alice has 9_300_000 
    Burn::epoch_start_burn(&vm, @Alice, 100000);

    let bal_alice = DiemAccount::balance<GAS>(@Alice);
    // print(&bal_alice);
    
    assert!(
      (bal_alice == 8900002), 7357010
    ); // 2 is from rounding issues
    
    // Check that the matching donations are being made
    let bal_a = DiemAccount::balance<GAS>(@CommunityA);
    // print(&bal_bob);
    assert!(bal_a > bal_A_before, 7357011);

    // unchanged balance since it received no donations
    let bal_b = DiemAccount::balance<GAS>(@CommunityB);
    assert!(bal_b > bal_B_before, 7357012);

    let total_supply_after = Diem::market_cap<GAS>();

    assert!(total_supply_after == total_supply_before, 7357013);

  }
}
// check: EXECUTED



