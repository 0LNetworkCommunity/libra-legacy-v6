//! account: alice, 1000000, 0, validator
//! account: bob, 1000000

//! new-transaction
//! sender: bob
script {
    use 0x1::Wallet;
    use 0x1::Vector;
    use 0x1::LibraAccount;

    fun main(sender: &signer) {
      Wallet::set_comm(sender);
      LibraAccount::init_cumulative_deposits(sender);
      let list = Wallet::get_comm_list();
      assert(Vector::length(&list) == 1, 7357001);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  use 0x1::Burn;
  use 0x1::Debug::print;

  fun main(vm: &signer) {
    // Should be fine if the balance is 0
    LibraAccount::vm_make_payment_no_limit<GAS>(
      {{alice}},
      {{bob}}, // has a 0 in balance
      100,
      x"",
      x"",
      vm
    );

    let bal = LibraAccount::balance<GAS>({{bob}});
    assert(bal == 1000100, 7357001);

    Burn::reset_ratios(vm);
    let (addr, _ , _) = Burn::get_ratios();
    print(&addr);

  }
}
// check: EXECUTED