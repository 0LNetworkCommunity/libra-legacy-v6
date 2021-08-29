//! account: alice, 1000000GAS, 0, validator
//! account: bob, 1000000GAS
//! account: carol, 1000000GAS

//! new-transaction
//! sender: bob
script {
    use 0x1::Wallet;
    use 0x1::Vector;
    use 0x1::GAS::GAS;
    use 0x1::Signer;
    use 0x1::DiemAccount;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
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
    use 0x1::GAS::GAS;
    use 0x1::Signer;
    use 0x1::DiemAccount;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert(Vector::length(&list) == 2, 7357002);
    }
}

// // check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;
  use 0x1::Burn;
  use 0x1::Vector;
  use 0x1::FixedPoint32;
  use 0x1::Debug::print;

  fun main(vm: signer) {
    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>( @{{alice}}, @{{bob}}, 100000, x"", x"", &vm);
    // send to community wallet Carol
    DiemAccount::vm_make_payment_no_limit<GAS>( @{{alice}}, @{{carol}}, 600000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@{{bob}});
    print(&bal);

    assert(bal == 1100000, 7357003);
    let bal = DiemAccount::balance<GAS>(@{{carol}});
    print(&bal);
    assert(bal == 1600000, 7357004);

    Burn::reset_ratios(&vm);
    let (addr, _ , ratios) = Burn::get_ratios();
    assert(Vector::length(&addr) == 2, 7357005);

    let carol_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
    let pct_carol = FixedPoint32::multiply_u64(100, carol_mult);
    print(&pct_carol);
    // ratio for carol's community wallet.
    assert(pct_carol == 59, 7357006);

    Burn::epoch_start_burn(&vm, @{{alice}}, 100);

    let bal_alice = DiemAccount::balance<GAS>(@{{alice}});
    print(&bal_alice);
    assert(bal_alice == 299901, 7357007); // rounding issues
    let bal_bob = DiemAccount::balance<GAS>(@{{bob}});
    print(&bal_bob);
    assert(bal_bob == 1100040, 7357008);

    let bal_carol = DiemAccount::balance<GAS>(@{{carol}});
    print(&bal_carol);

    assert(bal_carol == 1600059, 7357009);
  }
}
// check: EXECUTED

