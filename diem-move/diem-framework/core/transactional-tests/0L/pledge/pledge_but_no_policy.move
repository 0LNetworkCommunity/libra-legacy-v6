//# init --validators Alice Bob Carol

// Scenario: Bob wants to pledge to Alice. But Alice has not set up a policy yet. Should abort.



//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::PledgeAccounts;

  fun main(_vm: signer, a_sig: signer) {
    // TODO: update for coins.
    PledgeAccounts::add_funds_to_pledge_account(&a_sig, @Alice, 100);
    let amount = PledgeAccounts::get_user_pledge_amount(&@Bob, &@Alice);
    assert!(amount == 100, 735702);
  }
}

