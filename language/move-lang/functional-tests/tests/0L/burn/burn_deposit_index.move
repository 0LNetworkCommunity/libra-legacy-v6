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

// check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;

  fun main(vm: &signer) {
    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>( @{{alice}}, @{{bob}}, 500000, x"", x"", &vm);
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


//! new-transaction
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;
  use 0x1::Burn;
  use 0x1::Vector;
  use 0x1::FixedPoint32;

  fun main(vm: &signer) {
    // send to community wallet Carol
    DiemAccount::vm_make_payment_no_limit<GAS>( @{{alice}}, @{{carol}}, 500000, x"", x"", &vm);

    let bal = DiemAccount::balance<GAS>(@{{bob}});
    assert(bal == 500000, 7357003);
    let index = DiemAccount::get_index_cumu_deposits(@{{bob}});
    assert(index == 502500, 7357004);

    let bal = DiemAccount::balance<GAS>(@{{carol}});
    assert(bal == 500000, 7357005);
    let index = DiemAccount::get_index_cumu_deposits(@{{carol}});
    assert(index == 505000, 7357006);

    Burn::reset_ratios(&vm);
    let (addr, _ , ratios) = Burn::get_ratios();
    assert(Vector::length(&addr) == 2, 7357007);

    let bob_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 0);
    let pct_bob = FixedPoint32::multiply_u64(100000, bob_mult);
    assert(pct_bob == 49875, 7357008);

    let carol_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
    let pct_carol = FixedPoint32::multiply_u64(100000, carol_mult);
    assert(pct_carol == 50124, 7357009);
  }
}
// check: EXECUTED