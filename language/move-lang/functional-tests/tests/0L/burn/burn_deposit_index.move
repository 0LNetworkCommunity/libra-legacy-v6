//! account: alice, 1000000, 0, validator
//! account: bob, 0
//! account: carol, 0

// Tests the weighted average adjusted
// sends same amounts over different times.

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

  fun main(vm: &signer) {
    // send to community wallet Bob
    LibraAccount::vm_make_payment_no_limit<GAS>( {{alice}}, {{bob}}, 500000, x"", x"", vm);
  }
}


//////////////////////////////////////////////
/// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////

//////////////////////////////////////////////
/// Trigger reconfiguration at 130 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 130000000

////// TEST RECONFIGURATION IS HAPPENING /////
// check: NewEpochEvent
//////////////////////////////////////////////


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
    // send to community wallet Carol
    LibraAccount::vm_make_payment_no_limit<GAS>( {{alice}}, {{carol}}, 500000, x"", x"", vm);

    let bal = LibraAccount::balance<GAS>({{bob}});
    assert(bal == 500000, 7357003);

    let index = LibraAccount::get_index_cumu_deposits({{bob}});
    print(&0x22222);
    print(&index);

    let bal = LibraAccount::balance<GAS>({{carol}});
    assert(bal == 500000, 7357004);

    let index = LibraAccount::get_index_cumu_deposits({{bob}});
    print(&index);
    

    Burn::reset_ratios(vm);
    let (addr, _ , ratios) = Burn::get_ratios();
    assert(Vector::length(&addr) == 2, 7357005);

    let bob_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 0);
    let pct_bob = FixedPoint32::multiply_u64(100000, bob_mult);
    print(&0x01111111111);
    print(&pct_bob);

    let carol_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
    let pct_carol = FixedPoint32::multiply_u64(100000, carol_mult);
    print(&0x01111111111);
    print(&pct_carol);
    // ratio for carol's community wallet.
    // assert(pct_carol == 75, 7357006);

    Burn::epoch_start_burn(vm, {{alice}}, 100);

    let bal_alice = LibraAccount::balance<GAS>({{alice}});
    print(&bal_alice);
    // assert(bal_alice == 999500, 7357007);

    let bal_bob = LibraAccount::balance<GAS>({{bob}});
    print(&bal_bob);
    // assert(bal_bob == 125, 7357007);

    let bal_carol = LibraAccount::balance<GAS>({{carol}});
    print(&bal_carol);
    // assert(bal_carol == 375, 7357007);
  }
}
// check: EXECUTED