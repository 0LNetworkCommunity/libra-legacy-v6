//# init --validators Dummy
//#      --addresses Alice=0x2e3a0b7a741dae873bf0f203a82dfd52
//#                  Bob=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Alice=e1acb70a23dba96815db374b86c5ae96d6a9bc5fff072a7a8e55a1c27c1852d8
//#                     Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7

// Todo: These GAS values have no effect, all accounts start with 1M GAS

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


//# run --admin-script --signers DiemRoot DiemRoot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(vm: signer, _: signer) {
      let bob_balance = DiemAccount::balance<GAS>(@Bob);
      assert!(bob_balance == 1000000, 7357004);

      DiemAccount::process_community_wallets(&vm, 4);

      let bob_balance = DiemAccount::balance<GAS>(@Bob);
      assert!(bob_balance == 1000100, 7357005);

      // assert the community wallet queue has moved the pending transfer to the completed
      let list: vector<Wallet::TimedTransfer> = Wallet::list_transfers(0);
      assert!(Vector::length(&list) == 0, 7357006);

      let list: vector<Wallet::TimedTransfer> = Wallet::list_transfers(1);
      assert!(Vector::length(&list) == 1, 7357007);

      let list: vector<Wallet::TimedTransfer> = Wallet::list_transfers(2);
      assert!(Vector::length(&list) == 0, 7357008);
    }
}
// check: EXECUTED