
// Todo: These GAS values have no effect, all accounts start with 1M GAS
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


//! new-transaction
//! sender: diemroot
script {
    use DiemFramework::DiemAccount;
    use DiemFramework::GAS::GAS;

    fun main(vm: signer) {
      let bob_balance = DiemAccount::balance<GAS>(@Bob);
      assert!(bob_balance == 1000000, 7357004);

      DiemAccount::process_community_wallets(&vm, 4);

      let bob_balance = DiemAccount::balance<GAS>(@Bob);
      assert!(bob_balance == 1000100, 7357005);
    }
}

// check: EXECUTED