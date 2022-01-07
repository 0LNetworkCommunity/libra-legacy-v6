//! account: bob, 10000000, 0, validator

//! new-transaction
//! sender: bob
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;

  fun main(sender: signer) {
    // Some fake account.

    let new_account: address = @0x3DC18D1CF61FAAC6AC70E3A63F062E4A;
    let new_account_authkey_prefix = x"2bffcbd0e9016013cb8ca78459f69d2a";
    let value = 10000000; // exceeds Bob's transaction limit

    // This should fail with account limit exceeded error
    let eve_addr = DiemAccount::create_user_account_with_coin(
      &sender,
      new_account,
      new_account_authkey_prefix,
      value,
    );

    assert(DiemAccount::balance<GAS>(eve_addr) == value, 735701);

    // is NOT a slow wallet
    assert(!DiemAccount::is_slow(eve_addr), 735702);
  }
}
// check: "ABORTED { code: 120128,"
