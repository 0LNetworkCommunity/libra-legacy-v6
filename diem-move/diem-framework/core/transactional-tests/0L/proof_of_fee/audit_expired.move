//# init --validators Alice Bob Carol

// Scenario: Happy case. Alice checks all the boxes.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::ProofOfFee;
  use DiemFramework::Jail;
  use DiemFramework::Vouch;
  use DiemFramework::Testnet;
  use DiemFramework::DiemAccount;

  // use DiemFramework::Debug::print;

  fun main(vm: signer, a_sig: signer) {
    // let's remove testnet settings. Globals thresholds
    // are not the same as prod.
    Testnet::remove_testnet(&vm);

    // is not jailed.
    assert!(!Jail::is_jailed(@Alice), 1003);
    
    // has minimum viable vouches
    // bob and carol at genesis are automatically vouching for each other.
    // // print(&Vouch::unrelated_buddies(@Alice));
    assert!(Vouch::unrelated_buddies_above_thresh(@Alice), 1004);

    
    // check that there are sufficient UNLOCKED coins in the
    // validator's account.
    ProofOfFee::set_bid(&a_sig, 1, 1000); // mock a bid. change below
    let (bid, _) = ProofOfFee::current_bid(@Alice);
    DiemAccount::slow_wallet_epoch_drip(&vm, 500000); // mock funds in account
    let coin = DiemAccount::unlocked_amount(@Alice);
    let (r, _, _) = ProofOfFee::get_consensus_reward();
    let bid_cost = (bid * r) / 1000;
    // print(&bid_cost);
    assert!(coin > bid_cost, 1005);

    


    // has a bid which IS expired
    // test runner is at epoch 1, they put expiry at 0.
    // TODO: Improve this test by doing more advanced epochs
    ProofOfFee::set_bid(&a_sig, 1, 0); 
    let (bid, expires) = ProofOfFee::current_bid(@Alice);
    assert!(bid == 1, 1006);
    assert!(expires == 0, 1007);
    // should NOT pass audit.
    assert!(!ProofOfFee::audit_qualification(&@Alice), 1008);

    // fix it
    ProofOfFee::set_bid(&a_sig, 1, 1000); 
    assert!(ProofOfFee::audit_qualification(&@Alice), 1009);
  }
}