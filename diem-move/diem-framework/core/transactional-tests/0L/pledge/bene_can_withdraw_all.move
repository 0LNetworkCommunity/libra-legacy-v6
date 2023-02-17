//# init --validators Alice Bob Carol

// Scenario: Alice is creating a project she wants people to pledge to (beneficiary). Bob AND Carol will pledge. Can the beneficiary withdraw from both accounts?

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

  fun main(_vm: signer, b_sig: signer) {
    // TODO: update for coins.
    PledgeAccounts::add_funds_to_pledge_account(&b_sig, @Alice, 100);
    let amount = PledgeAccounts::get_user_pledge_amount(&@Bob, &@Alice);
    assert!(amount == 100, 735702);
  }
}

//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::PledgeAccounts;

  fun main(_vm: signer, c_sig: signer) {
    // TODO: update for coins.
    PledgeAccounts::add_funds_to_pledge_account(&c_sig, @Alice, 100);
    let amount = PledgeAccounts::get_user_pledge_amount(&@Carol, &@Alice);
    assert!(amount == 100, 735703);
  }
}

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::PledgeAccounts;
  use DiemFramework::Debug::print;

  fun main(_vm: signer, a_sig: signer) {
    // TODO: update for coins.

    let (t, _) = PledgeAccounts::get_lifetime_to_beneficiary(&@Alice);
    assert!(t == 200, 735704);
    // Withdraw 10 coins.
    PledgeAccounts::withdraw_from_all_pledge_accounts(&a_sig, 10);
    // assert!(c == 10, 735703);
    let amount = PledgeAccounts::get_user_pledge_amount(&@Bob, &@Alice);
    assert!(amount == 90, 735705);

    let amount = PledgeAccounts::get_user_pledge_amount(&@Carol, &@Alice);
    print(&amount);
    assert!(amount == 90, 735706);

    // available is reduced
    let avail = PledgeAccounts::get_available_to_beneficiary(&@Alice);
    assert!(avail == 180, 735707);
    // total should not change
    let (t, _) = PledgeAccounts::get_lifetime_to_beneficiary(&@Alice);
    assert!(t == 200, 735708);
  }
}


