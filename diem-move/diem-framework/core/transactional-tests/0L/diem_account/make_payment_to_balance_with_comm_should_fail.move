//! account: alice, 1000GAS, 0, validator
//! account: bob, 1000000GAS // the slow wallet
//! account: carol, 0GAS     // the community wallet

// Community wallets cannot use the slow wallet transfer scripts

//! new-transaction
//! sender: bob
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::Vector;

  fun main(bob: signer) {
    // BOB Sets wallet to slow wallet
    DiemAccount::set_slow(&bob);
    let list = DiemAccount::get_slow_list();
    // alice, the validator, is already a slow wallet, adding bob
    assert!(Vector::length<address>(&list) == 2, 735701);
  }
}
// check: EXECUTED

//! new-transaction
//! sender: carol
script {
  use DiemFramework::Wallet;
  use DiemFramework::Vector;

  fun main(carol: signer) {
    Wallet::set_comm(&carol);
    let list = Wallet::get_comm_list();
    assert!(Vector::length(&list) == 1, 7357001);
  }
}
// check: EXECUTED

//! new-transaction
//! sender: carol
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(carol: signer) {
       // CAROL the community wallet sends funds to BOB the slow wallet
        let value = 1000;
        let with_cap = DiemAccount::extract_withdraw_capability(&carol);
        DiemAccount::pay_from<GAS>(&with_cap, @Bob, value, b"balance_transfer", b"");
        DiemAccount::restore_withdraw_capability(with_cap);
    
  }
}
// check: ABORTED