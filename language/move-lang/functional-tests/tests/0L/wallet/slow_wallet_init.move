///// Setting up the test fixtures for the transactions below. The tags below create validators alice and bob, giving them 1000000 GAS coins.

//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS,


//! new-transaction
//! sender: bob
script {
    use 0x1::Wallet;
    use 0x1::Vector;

    fun main(sender: signer) {
      let list = Wallet::get_slow_list();
      // alice, the validator, is already a slow wallet.
      assert(Vector::length(&list) == 1, 7357001);

      Wallet::set_slow(&sender);
      let list = Wallet::get_slow_list();
      assert(Vector::length(&list) == 2, 7357002);
    }
}

// check: EXECUTED
