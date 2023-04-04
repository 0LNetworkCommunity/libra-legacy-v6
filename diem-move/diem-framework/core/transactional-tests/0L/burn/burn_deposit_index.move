//# init --validators Alice Bob Dave CommunityA CommunityB

// We will set up two community wallets A and B.
// The deposit tracker should tell us the proportion that
// has been donoated to each.

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
  use DiemFramework::Debug::print;
  use DiemFramework::GAS::GAS;
  
  fun main(vm: signer, _account: signer) {
    // bobs_indexed amount changes
    let index_A_before = DiemAccount::get_index_cumu_deposits(@CommunityA);
    let index_B_before = DiemAccount::get_index_cumu_deposits(@CommunityB);
    print(&index_A_before);
    // print(&index_B_before);

    // send to community wallet CommunityA
    DiemAccount::vm_make_payment_no_limit<GAS>( @Alice, @CommunityA, 100000, x"", x"", &vm);
    let index_A_after = DiemAccount::get_index_cumu_deposits(@CommunityA);
    print(&index_A_after);
    assert!(index_A_after > index_A_before, 735705);

    // CommunityB's amount DOES NOT change
    let index_B_after = DiemAccount::get_index_cumu_deposits(@CommunityB);
    assert!(index_B_before == index_B_after, 735706)
  }
}