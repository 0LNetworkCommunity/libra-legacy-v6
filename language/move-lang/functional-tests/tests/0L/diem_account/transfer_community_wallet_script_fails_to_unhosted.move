//! account: alice, 1000GAS, 0, validator
//! account: bob, 0GAS // the slow wallet
//! account: carol, 1000000000GAS     // the community wallet

// Community wallets cannot use the slow wallet transfer scripts

//! new-transaction
//! sender: bob
script {
  use 0x1::DiemAccount;
  use 0x1::Vector;

  fun main(_bob: signer) {
    // BOB Sets wallet to slow wallet
    // DiemAccount::set_slow(&bob);
    let list = DiemAccount::get_slow_list();
    // alice, the validator, is already a slow wallet, adding bob
    assert(Vector::length<address>(&list) == 1, 735701);
  }
}
// check: EXECUTED

//! new-transaction
//! sender: carol
script {
  use 0x1::Wallet;
  use 0x1::Vector;

  fun main(carol: signer) {
    Wallet::set_comm(&carol);
    let list = Wallet::get_comm_list();
    assert(Vector::length(&list) == 1, 7357001);
  }
}
// check: EXECUTED

//! new-transaction
//! sender: carol
//! args: {{bob}}, 1, b"thanks for your service"
stdlib_script::TransferScripts::community_transfer
// check: ABORTED
