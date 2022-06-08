//# init --validators Bob

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(_dr: signer, sender: signer) {
    // Eve's account info.
    let new_account: address = @0x3DC18D1CF61FAAC6AC70E3A63F062E4B;
    let new_account_authkey_prefix = x"2bffcbd0e9016013cb8ca78459f69d2b";
    let value = 1000000; // minimum is 1m microgas

    let eve_addr = DiemAccount::create_user_account_with_coin(
      &sender,
      new_account,
      new_account_authkey_prefix,
      value,
    );

    assert!(DiemAccount::balance<GAS>(eve_addr) == 1000000, 735701);

    // is NOT a slow wallet
    assert!(!DiemAccount::is_slow(eve_addr), 735702);
  }
}
// check: EXECUTED