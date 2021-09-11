///// Setting up the test fixtures for the transactions below. The tags below create validators alice and bob, giving them 1000000 GAS coins.

//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS,


//! new-transaction
//! sender: bob
script {
    // use 0x1::Wallet;
    use 0x1::DiemAccount;
    // use 0x1::Vector;
    use 0x1::Debug::print;

    fun main(_sender: signer) {
      let list = DiemAccount::get_slow_list();
      // alice, the validator, is already a slow wallet.
      print(&list);
    }
}

// check: EXECUTED
