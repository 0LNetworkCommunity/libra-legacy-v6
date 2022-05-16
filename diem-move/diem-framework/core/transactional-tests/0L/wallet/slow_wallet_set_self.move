//! account: alice, 1000GAS, 0, validator
//! account: bob, 1000000GAS

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::DiemAccount;
  use Std::Vector;

  fun main(bob: signer) {
    // BOB Sets wallet to slow wallet
    DiemAccount::set_slow(&bob);
    let list = DiemAccount::get_slow_list();
    // alice, the validator, is already a slow wallet, adding bob
    assert!(Vector::length<address>(&list) == 2, 735701);
  }
}
// check: EXECUTED
