//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS,

// Tests that the slow wallet list at 0x0 is initialized at genesis, with validators (1)
//! new-transaction
//! sender: bob
script {
    use DiemFramework::DiemAccount;
    use Std::Vector;

    fun main(_sender: signer) {
      let list = DiemAccount::get_slow_list();
      // alice, the validator, is already a slow wallet.
      assert!(Vector::length<address>(&list) ==1, 735701);
    }
}

// check: EXECUTED
