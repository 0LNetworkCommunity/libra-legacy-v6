//! account: alice, 1000GAS, 0, validator
//! account: bob, 0GAS // an end-user wallet
//! account: carol, 10000000  00GAS // an end-user wallet with money

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Testnet;
  fun main(vm: signer) {
    // need to remove testnet for this test, because behavior is different in tests
    Testnet::remove_testnet(&vm);

    assert!(!DiemAccount::is_slow(@Bob), 735701);
    assert!(!DiemAccount::is_slow(@Carol), 735702);
    assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735703);
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
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  // use DiemFramework::Debug::print;
  fun main(_: signer) {    
    /// bob is initialized with 1,000,000 microgas, should now have one more.
    assert!(DiemAccount::balance<GAS>(@Bob) == 2000000, 735704);
  }
}