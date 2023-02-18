//# init --validators Alice Bob Carol

// Scenario: Bob wants to pledge to Alice. But Alice has not set up a policy yet. Should abort.



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
    assert!(amount > 0, 1001);
  }
}

