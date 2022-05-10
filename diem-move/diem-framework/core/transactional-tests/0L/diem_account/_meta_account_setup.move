//# init --validators Bob

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  fun main(_dr: signer, _: signer) {
    // need to remove testnet for this test,
    // since testnet does not ratelimit account creation.
    
    let bal = DiemAccount::balance<GAS>(@Bob);
    assert!(bal == 10000000, 7357001);
  }
}