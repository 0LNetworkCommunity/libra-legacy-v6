
// Todo: These GAS values have no effect, all accounts start with 1M GAS

//! account: dummy, 1000000GAS, 0, validator

//! account: alice, 1000000GAS, 0
//! account: bob,   1000000GAS, 0


//! new-transaction
//! sender: alice
script {
    use DiemFramework::Wallet;
    use Std::Vector;

    fun main(sender: signer) {
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