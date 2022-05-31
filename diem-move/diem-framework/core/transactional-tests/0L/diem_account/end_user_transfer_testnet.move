//# init --parent-vasps Alice Bob Jim Carol
// Alice, Jim:     validators with 10M GAS
// Bob, Carol: non-validators with  1M GAS

// Bob, an end-user wallet
// Carol, an end-user wallet

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  fun main() {
    // need to remove testnet for this test, since testnet does not ratelimit account creation.

    assert!(!DiemAccount::is_slow(@Bob), 735701);
    assert!(!DiemAccount::is_slow(@Carol), 735702);
    assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735703);
  }
}

//# run --signers Carol --args @Bob 1
//#     -- 0x1::TransferScripts::balance_transfer

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  // use DiemFramework::Debug::print;
  fun main() {
    // need to remove testnet for this test, since testnet does not ratelimit account creation.
    
    // bob is initialized with 1,000,000 microgas, should now have one more.
    assert!(DiemAccount::balance<GAS>(@Bob) == 2000000, 735704);

  }
}