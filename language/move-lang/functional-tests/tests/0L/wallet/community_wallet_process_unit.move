
// Todo: These GAS values have no effect, all accounts start with 1M GAS

//! account: dummy, 1000000GAS, 0, validator

//! account: alice, 1000000GAS, 0
//! account: bob,   1000000GAS, 0


//! new-transaction
//! sender: alice
script {
    use 0x1::Wallet;
    use 0x1::Vector;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let list = Wallet::get_comm_list();

      assert(Vector::length(&list) == 1, 7357001);
      assert(Wallet::is_comm(@{{alice}}), 7357002);

      let uid = Wallet::new_timed_transfer(&sender, @{{bob}}, 100, b"thanks bob");
      assert(Wallet::transfer_is_proposed(uid), 7357003);
    }
}

// check: EXECUTED


//! new-transaction
//! sender: diemroot
script {
    use 0x1::DiemAccount;
    use 0x1::GAS::GAS;
    use 0x1::Wallet;
    use 0x1::Vector;

    fun main(vm: signer) {
      let bob_balance = DiemAccount::balance<GAS>(@{{bob}});
      assert(bob_balance == 1000000, 7357004);

      DiemAccount::process_community_wallets(&vm, 3);

      let bob_balance = DiemAccount::balance<GAS>(@{{bob}});
      assert(bob_balance == 1000100, 7357005);

      // assert the community wallet queue has moved the pending transfer to the completed
      let list: vector<Wallet::TimedTransfer> = Wallet::list_transfers(0);
      assert(Vector::length(&list) == 0, 7357006);

      let list: vector<Wallet::TimedTransfer> = Wallet::list_transfers(1);
      assert(Vector::length(&list) == 1, 7357007);

      let list: vector<Wallet::TimedTransfer> = Wallet::list_transfers(2);
      assert(Vector::length(&list) == 0, 7357008);
    }
}

// check: EXECUTED