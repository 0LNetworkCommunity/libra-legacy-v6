//# init --validators Alice Bob Carol

// Scenario: Alice is creating a project she wants people to pledge to (beneficiary). Bob wants to pledge. Can he segregate coins into a pledge account.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::PledgeAccounts;

  // use DiemFramework::Debug::print;

  fun main(_vm: signer, a_sig: signer) {
    
    let purpose = b"ban jackhammers";
    let vote_threshold_to_revoke = 20; // 20% of pledgers (by coin value) can vote to dissolve, and revoke.
    let burn_funds_on_revoke = true; // high stakes! You don't get the money back if you vote to dissolve. Useful for community policies.
    PledgeAccounts::publish_beneficiary_policy(
      &a_sig,
      purpose,
      vote_threshold_to_revoke,
      burn_funds_on_revoke,
    );

    let (t, _) = PledgeAccounts::get_lifetime_to_beneficiary(&@Alice);
    assert!(t == 0, 735701);
  }
}


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::PledgeAccounts;
  use DiemFramework::DiemAccount;

  fun main(vm: signer, b_sig: signer) {
    // TODO: update for coins.
    // mock the validators unlocked coins.
    DiemAccount::slow_wallet_epoch_drip(&vm, 1000);
    let coin = DiemAccount::simple_withdrawal(&b_sig, 100);
    PledgeAccounts::save_pledge(&b_sig, @Alice, coin);
    let amount = PledgeAccounts::get_user_pledge_amount(&@Bob, &@Alice);
    assert!(amount == 100, 735702);
  }
}

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::PledgeAccounts;
  use DiemFramework::Diem;  
  use DiemFramework::DiemAccount;
  use Std::Option;

  fun main(vm: signer, _a_sig: signer) {
    // TODO: update for coins.
    // Withdraw 10 coins.
    let opt = PledgeAccounts::test_single_withdrawal(&vm, &@Alice, &@Bob, 10);
    let coins = Option::extract(&mut opt);
    Option::destroy_none(opt);
    assert!(Diem::value(&coins) == 10, 735703);

    // get rid of these coins
    DiemAccount::vm_deposit_with_metadata(
      &vm,
      @VMReserved,
      @Alice,
      coins,
      b"", 
      b"",
    );

    let amount = PledgeAccounts::get_user_pledge_amount(&@Bob, &@Alice);
    assert!(amount == 90, 735703);
  }
}


