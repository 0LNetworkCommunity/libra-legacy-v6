//# init --validators Bob

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  // use DiemFramework::Debug::print;
  fun main(_dr: signer, _: signer) {
    // need to remove testnet for this test,
    // since testnet does not ratelimit account creation.
    
    let bal = DiemAccount::balance<GAS>(@Bob);
    // print(&bal);

    assert!(bal == 10000000, 7357001);

    // at genesis the root account is also funded
    let bal = DiemAccount::balance<GAS>(@DiemRoot);
    assert!(bal == 10000000, 7357002);
  }
}