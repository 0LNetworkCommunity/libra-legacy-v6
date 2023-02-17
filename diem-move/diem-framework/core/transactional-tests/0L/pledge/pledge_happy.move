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

    assert!(PledgeAccounts::get_total_pledged_to_beneficiary(@Alice) == 0, 735701);
  }
}


//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::PledgeAccounts;

  fun main(_vm: signer, a_sig: signer) {
    // TODO: update for coins.
    PledgeAccounts::add_funds_to_pledge_account(&a_sig, @Alice, 100);
    let amount = PledgeAccounts::get_pledge_amount(&@Bob, &@Alice);
    assert!(amount == 100, 735702);
  }
}

