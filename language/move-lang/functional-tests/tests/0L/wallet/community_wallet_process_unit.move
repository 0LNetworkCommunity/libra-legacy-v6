//! account: alice, 1000000, 0
//! account: bob, 1000000, 0


//! new-transaction
//! sender: alice
script {
    use 0x1::Wallet;
    use 0x1::Vector;

    fun main(sender: &signer) {
      Wallet::set_comm(sender);
      let list = Wallet::get_comm_list();

      assert(Vector::length(&list) == 1, 7357001);
      assert(Wallet::is_comm({{alice}}), 7357002);

      let uid = Wallet::new_timed_transfer(sender, {{bob}}, 100, b"thanks bob");
      assert(Wallet::transfer_is_proposed(uid), 7357003);
    }
}

// check: EXECUTED


//! new-transaction
//! sender: libraroot
script {
    use 0x1::LibraAccount;
    use 0x1::LibraConfig;
    use 0x1::GAS::GAS;
    use 0x1::Debug::print;

    fun main(vm: &signer) {

      let e = LibraConfig::get_current_epoch();
      print(&e);
      let bob_balance = LibraAccount::balance<GAS>({{bob}});

      print(&bob_balance);
      LibraAccount::process_community_wallets(vm, 4);
    }
}

// check: EXECUTED