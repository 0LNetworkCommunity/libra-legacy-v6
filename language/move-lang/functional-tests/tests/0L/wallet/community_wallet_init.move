///// Setting up the test fixtures for the transactions below. The tags below create validators alice and bob, giving them 1000000 GAS coins.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

//! new-transaction
//! sender: libraroot
script {
    use 0x1::Wallet;

    fun main(vm: &signer) {
      Wallet::init_comm_list(vm);
    }
}

// check: EXECUTED


//! new-transaction
//! sender: alice
script {
    use 0x1::Wallet;
    use 0x1::Vector;

    fun main(sender: &signer) {
      Wallet::set_comm(sender);
      let list = Wallet::get_comm_list();
      assert(Vector::length(&list) == 1, 7357001);

      Wallet::remove_comm(sender);
      let list = Wallet::get_comm_list();
      assert(Vector::length(&list) == 0, 7357002);

    }
}

// check: EXECUTED