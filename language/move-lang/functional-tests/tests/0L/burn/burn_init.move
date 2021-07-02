//! account: alice, 1000000, 0, validator
//! account: bob, 0
//! account: carol, 0

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
      assert(Vector::length(&list) == 2, 7357002);
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
  use 0x1::Debug::print;

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
      300,
      x"",
      x"",
      vm
    );

    let bal = LibraAccount::balance<GAS>({{bob}});
    assert(bal == 1000100, 7357003);
    let bal = LibraAccount::balance<GAS>({{carol}});
    assert(bal == 1000300, 7357004);

    Burn::reset_ratios(vm);
    let (addr, _ , ratios) = Burn::get_ratios();

    assert(Vector::length(&addr) == 2, 7357005);
    let pct = FixedPoint32::multiply_u64(
      100,
      Vector::pop_back<FixedPoint32::FixedPoint32>(&mut ratios)
    );

    // ratio for carol's community wallet.
    print(&pct);
    // assert(pct == 75, 7357006);

    Burn::epoch_start_burn(vm, {{alice}}, 100);
    let bal_alice = LibraAccount::balance<GAS>({{alice}});
    print(&bal_alice);

    let bal_bob = LibraAccount::balance<GAS>({{bob}});
    print(&bal_bob);

    // assert(bal_bob == 1000150, 7357001);
    let bal_carol = LibraAccount::balance<GAS>({{carol}});
    // assert(bal_carol == 1000150, 7357001);
    print(&bal_carol);
  }
}
// check: EXECUTED

