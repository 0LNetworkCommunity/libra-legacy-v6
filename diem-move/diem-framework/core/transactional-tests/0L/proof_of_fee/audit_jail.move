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
    
    // has minimum viable vouches
    // bob and carol at genesis are automatically vouching for each other.
    // // print(&Vouch::unrelated_buddies(@Alice));
    assert!(Vouch::unrelated_buddies_above_thresh(@Alice), 1004);

    // has a bid which has not expired
    ProofOfFee::set_bid(&a_sig, 1, 10000);
    let (bid, expires) = ProofOfFee::current_bid(@Alice);
    assert!(bid == 1, 1001);
    assert!(expires == 10000, 1002);


    // check that there are sufficient UNLOCKED coins in the
    // validator's account.
    DiemAccount::slow_wallet_epoch_drip(&vm, 500000);
    let coin = DiemAccount::unlocked_amount(@Alice);
    let (r, _, _) = ProofOfFee::get_consensus_reward();
    let bid_cost = (bid * r) / 1000;
    // print(&bid_cost);
    assert!(coin > bid_cost, 1005);


    // EVERYTHING ABOVE HERE IS PASSING.
    // is now jailed.
    Jail::jail(&vm, @Alice);
    assert!(Jail::is_jailed(@Alice), 1006);
    // won't pass audit
    assert!(!ProofOfFee::audit_qualification(&@Alice), 1007);
    

    
  }
}

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::ProofOfFee;
    use DiemFramework::Jail;
    fun main(_vm: signer, bob_sig: signer) {
      
      // Bob needs to unjail
      Jail::vouch_unjail(&bob_sig, @Alice);

      // should pass audit.
      assert!(ProofOfFee::audit_qualification(&@Alice), 1008);


    }
}
