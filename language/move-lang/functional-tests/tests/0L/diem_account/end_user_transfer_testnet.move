//! account: alice, 1000GAS, 0, validator
//! account: bob, 0GAS // an end-user wallet
//! account: carol, 10000000  00GAS // an end-user wallet with money

//! new-transaction
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;
  fun main(_: signer) {
    // need to remove testnet for this test, since testnet does not ratelimit account creation.

    assert(!DiemAccount::is_slow(@{{bob}}), 735701);
    assert(!DiemAccount::is_slow(@{{carol}}), 735702);
    assert(DiemAccount::balance<GAS>(@{{bob}}) == 1000000, 735703);
  }
}

//! new-transaction
//! sender: carol
//! args: {{bob}}, 1
stdlib_script::TransferScripts::balance_transfer
// check: "Keep(EXECUTED)"


//! new-transaction
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;
  // use 0x1::Debug::print;
  fun main(_: signer) {
    // need to remove testnet for this test, since testnet does not ratelimit account creation.
    
    /// bob is initialized with 1,000,000 microgas, should now have one more.
    assert(DiemAccount::balance<GAS>(@{{bob}}) == 2000000, 735704);

  }
}