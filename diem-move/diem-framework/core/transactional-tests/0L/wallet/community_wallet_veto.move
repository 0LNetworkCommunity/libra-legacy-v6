//# init --validators Carol Dave
//#      --addresses Alice=0x2e3a0b7a741dae873bf0f203a82dfd52
//#                  Bob=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Alice=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8
//#                     Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7

///// Setting up the test fixtures for the transactions below. 
///// The tags below create validators alice and bob, giving them 1000000 GAS coins.

// alice is a community wallet
// bob is a recipient of the community wallet
// carol and dave are validators, that vote to reject the transaction

// Set voting power of the validtors

//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::TowerState;
    fun main(vm: signer, _: signer) {
      TowerState::test_helper_set_weight_vm(&vm, @Carol, 50);
      TowerState::test_helper_set_weight_vm(&vm, @Dave, 50);
    }
}
// check: EXECUTED


//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(_dr: signer, sender: signer) {
      Wallet::set_comm(&sender);
      let list = Wallet::get_comm_list();

      assert!(Vector::length(&list) == 1, 7357001);
      assert!(Wallet::is_comm(@Alice), 7357002);

      let uid = Wallet::new_timed_transfer(&sender, @Bob, 100, b"thanks bob");
      assert!(Wallet::transfer_is_proposed(uid), 7357003);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::Wallet;

    fun main(_dr: signer, sender: signer) {
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

//# run --admin-script --signers DiemRoot Dave
script {
    use DiemFramework::Wallet;

    fun main(_dr: signer, sender: signer) {
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