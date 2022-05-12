//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#                  Carol=0xeadf5eda5e7d5b9eea4a119df5dc9b26
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7
//#                     Carol=80942c213a3ab47091dfb6979326784856f46aad26c4946aea4f9f0c5c041a79
//// Old syntax for reference, delete it after fixing this test
//! account: alice, 1000GAS, 0, validator
//! account: bob, 0GAS // the slow wallet
//! account: carol, 1000000000GAS     // the community wallet

// Community wallets cannot use the slow wallet transfer scripts

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::DiemAccount;
  use Std::Vector;

  fun main(_dr: signer, bob: signer) {
    // BOB Sets wallet to slow wallet
    DiemAccount::set_slow(&bob);
    let list = DiemAccount::get_slow_list();
    // alice, the validator, is already a slow wallet, adding bob
    assert!(Vector::length<address>(&list) == 2, 735701);
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::Wallet;
  use Std::Vector;

  fun main(_dr: signer, carol: signer) {
    Wallet::set_comm(&carol);
    let list = Wallet::get_comm_list();
    assert!(Vector::length(&list) == 1, 7357001);
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
//! args: {{bob}}, 1, b"thanks for your service"
stdlib_script::TransferScripts::community_transfer
// check: "Keep(EXECUTED)"
