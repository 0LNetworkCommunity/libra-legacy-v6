//# init --validators Alice Bob Dave Community

// Community, the community wallet
// Dave, the slow wallet

// Community wallets have specific tx script to send to slow wallet

//# run --admin-script --signers DiemRoot Dave
script {
  use DiemFramework::DiemAccount;
  use Std::Vector;

  fun main(_dr: signer, sender: signer) {
    DiemAccount::set_slow(&sender);
    let list = DiemAccount::get_slow_list();
    assert!(Vector::length<address>(&list) == 4, 735701);
  }
}

//# run --admin-script --signers DiemRoot Community
script {
  use DiemFramework::DonorDirected;
  use Std::Vector;

  fun main(_dr: signer, sponsor: signer) {
    // initialize the community wallet, @Community cannot be one of the signers
    DonorDirected::init_donor_directed(&sponsor, @Alice, @Bob, @Dave, 2);
    DonorDirected::finalize_init(&sponsor);
    let list = DonorDirected::get_root_registry();
    assert!(Vector::length(&list) == 1, 7357001);
  }
}

// COMMUNTIY WALLET IS TRYING TO USE THE NORMAL PAYMENT APIS. SHOULD FAIL

//# run --admin-script --signers DiemRoot Community
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(_dr: signer, community: signer) {
       // CAROL the community wallet sends funds to BOB the slow wallet
        let value = 1000;
        let with_cap = DiemAccount::extract_withdraw_capability(&community);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, value, b"balance_transfer", b"");
        DiemAccount::restore_withdraw_capability(with_cap);
  }
}
//check: ABORTED