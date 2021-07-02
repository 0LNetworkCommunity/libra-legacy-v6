//! account: alice, 1000000, 0, validator
//! account: bob, 1000000
//! account: carol, 1000000

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
//! sender: carol
script {
    use 0x1::Wallet;
    use 0x1::Vector;
    use 0x1::LibraAccount;

    fun main(sender: &signer) {
      Wallet::set_comm(sender);
      LibraAccount::init_cumulative_deposits(sender);
      let list = Wallet::get_comm_list();
      assert(Vector::length(&list) == 2, 7357001);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;
  use 0x1::Burn;
  use 0x1::Vector;
  use 0x1::FixedPoint32;

  fun main(vm: &signer) {
    // send to community wallet Bob
    LibraAccount::vm_make_payment_no_limit<GAS>(
      {{alice}},
      {{bob}}, // community wallet
      100,
      x"",
      x"",
      vm
    );

    // send to community wallet Carol
    LibraAccount::vm_make_payment_no_limit<GAS>(
      {{alice}},
      {{carol}}, // community wallet
      100,
      x"",
      x"",
      vm
    );

    let bal = LibraAccount::balance<GAS>({{bob}});
    assert(bal == 1000100, 7357001);
    let bal = LibraAccount::balance<GAS>({{carol}});
    assert(bal == 1000100, 7357001);

    Burn::reset_ratios(vm);
    let (addr, deps , ratios) = Burn::get_ratios();

    assert(Vector::length(&addr) == 2, 7357002);
    let pct = FixedPoint32::multiply_u64(100, Vector::pop_back<FixedPoint32::FixedPoint32>(&mut ratios));
    assert(pct == 50, 7357003);
  }
}
// check: EXECUTED