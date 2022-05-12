//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#                  Carol=0xeadf5eda5e7d5b9eea4a119df5dc9b26
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7
//#                     Carol=80942c213a3ab47091dfb6979326784856f46aad26c4946aea4f9f0c5c041a79
//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1000GAS, 0, validator
//! account: bob, 0GAS // an end-user wallet
//! account: carol, 10000000  00GAS // an end-user wallet with money

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Testnet;
  fun main(vm: signer, _: signer) {
    // need to remove testnet for this test, because behavior is different in tests
    Testnet::remove_testnet(&vm);

    assert!(!DiemAccount::is_slow(@Bob), 735701);
    assert!(!DiemAccount::is_slow(@Carol), 735702);
    assert!(DiemAccount::balance<GAS>(@Bob) == 1000000, 735703);
  }
}

//# run --admin-script --signers DiemRoot Carol
//! args: {{bob}}, 1
stdlib_script::TransferScripts::balance_transfer
// check: "Keep(EXECUTED)"

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  // use DiemFramework::Debug::print;
  fun main() {
    // bob is initialized with 1,000,000 microgas, should now have one more
    assert!(DiemAccount::balance<GAS>(@Bob) == 2000000, 735704);
  }
}