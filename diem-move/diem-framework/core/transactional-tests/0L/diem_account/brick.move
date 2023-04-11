//# init --validators Bob

// TODO: The test harness does not allow us to actually test real authkeys.

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  fun main(_dr: signer, b_sig: signer) {
    // need to remove testnet for this test,
    // since testnet does not ratelimit account creation.

    // initialized balance
    let bal = DiemAccount::balance<GAS>(@Bob);
    assert!(bal == 10000000, 7357001);

    // brick the account
    DiemAccount::brick_this(&b_sig, b"yes I know what I'm doing");

    // No changes
    let bal = DiemAccount::balance<GAS>(@Bob);
    assert!(bal == 10000000, 7357002);

    // NOTE: in the life of this transaction the previous authkey is still valid. I can issue another operation.
    // It's only in the next transaction that the account is bricked.

    // brick the account
    DiemAccount::brick_this(&b_sig, b"yes I know what I'm doing");

    assert!(DiemAccount::is_a_brick(@Bob),7357003);

  }
}
