///// Setting up the test fixtures for the transactions below. The tags below create validators alice and bob, giving them 1000000 GAS coins.

// alice is a community wallet
// bob is a recipient of the community wallet
// carol and dave are validators, that vote to reject the transaction

//! account: alice, 1000000, 0
//! account: bob, 1000000, 0
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator

// Set voting power of the validtors

//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::TowerState;
    fun main(vm: signer) {
      TowerState::test_helper_set_weight_vm(&vm, @{{carol}}, 50);
      TowerState::test_helper_set_weight_vm(&vm, @{{dave}}, 50);
    }
}
// check: EXECUTED


//! new-transaction
//! sender: alice
script {
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let list = Wallet::get_comm_list();

      assert!(Vector::length(&list) == 1, 7357001);
      assert!(Wallet::is_comm(@{{alice}}), 7357002);

      let uid = Wallet::new_timed_transfer(&sender, @{{bob}}, 100, b"thanks bob");
      assert!(Wallet::transfer_is_proposed(uid), 7357003);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use DiemFramework::Wallet;

    fun main(sender: signer) {
      let uid = 1;
      let e = Wallet::get_tx_epoch(uid);
      assert!(e == 4, 7357004);

      Wallet::veto(&sender, uid);


      let e = Wallet::get_tx_epoch(uid);
      // adds latency to tx
      assert!(e == 5, 7357005);

      assert!(Wallet::transfer_is_proposed(uid), 7357006);
      assert!(!Wallet::transfer_is_rejected(uid), 7357007);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: dave
script {
    use DiemFramework::Wallet;

    fun main(sender: signer) {
      let uid = 1;

      let e = Wallet::get_tx_epoch(uid);
      assert!(e == 5, 7357008);

      Wallet::veto(&sender, uid);

      let e = Wallet::get_tx_epoch(uid);
      assert!(e == 0, 7357009);

      assert!(!Wallet::transfer_is_proposed(uid), 7357010);
      assert!(Wallet::transfer_is_rejected(uid), 7357011);
    }
}

// check: EXECUTED