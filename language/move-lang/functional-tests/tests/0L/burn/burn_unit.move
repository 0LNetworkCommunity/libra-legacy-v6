//! account: alice, 2000000GAS, 0, validator
//! account: bob, 1000000GAS
//! account: carol, 1000000GAS


//! new-transaction
//! sender: alice
script {
    use 0x1::Burn;


    fun main(sender: signer) {
      // alice chooses a pure burn for all burns.
      Burn::set_send_community(&sender, false);
    }
}

// check: EXECUTED




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
    DiemAccount::vm_make_payment_no_limit<GAS>(@{{alice}}, @{{bob}}, 100000, x"", x"", &vm);
    // send to community wallet Carol
    DiemAccount::vm_make_payment_no_limit<GAS>(@{{alice}}, @{{carol}}, 600000, x"", x"", &vm);

    let bal_bob_old = DiemAccount::balance<GAS>(@{{bob}});

    assert(bal_bob_old == 1100000, 7357003);
    let bal_carol_old = DiemAccount::balance<GAS>(@{{carol}});

    assert(bal_carol_old == 1600000, 7357004);

    Burn::reset_ratios(&vm);
    let (addr, _ , ratios) = Burn::get_ratios();
    assert(Vector::length(&addr) == 2, 7357005);

    let carol_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
    let pct_carol = FixedPoint32::multiply_u64(100, carol_mult);
    // ratio for carol's community wallet.
    assert(pct_carol == 59, 7357006);

    Burn::epoch_start_burn(&vm, @{{alice}}, 100000);

    let bal_alice = DiemAccount::balance<GAS>(@{{alice}});
    print(&bal_alice);
    assert(
      (bal_alice >= 1199999 &&
      bal_alice <= 1200001)
      , 7357007); // rounding issues
    
    // unchanged balance
    let bal_bob = DiemAccount::balance<GAS>(@{{bob}});
    print(&bal_bob);

    assert(bal_bob == bal_bob_old, 7357008);

    // unchanged balance

    let bal_carol = DiemAccount::balance<GAS>(@{{carol}});
    assert(bal_carol == bal_carol_old, 7357009);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: alice
script {
  use 0x1::Burn;

  fun main(alice: signer) {

    Burn::set_send_community(&alice, true);
  }
}
//////// SETS community send

//! new-transaction
//! sender: diemroot
script {
  use 0x1::DiemAccount;
  use 0x1::GAS::GAS;
  use 0x1::Burn;

  fun main(vm: signer) {
    let bal_bob_old = DiemAccount::balance<GAS>(@{{bob}});
    let bal_carol_old = DiemAccount::balance<GAS>(@{{carol}});

    // this time alice changed burn settings, and is resending to community.
    Burn::epoch_start_burn(&vm, @{{alice}}, 100000);

    let bal_alice = DiemAccount::balance<GAS>(@{{alice}});
    assert(bal_alice == 1100001, 7357010); // rounding issues
    
    // balances are greater than before.
    let bal_bob = DiemAccount::balance<GAS>(@{{bob}});
    assert(bal_bob > bal_bob_old, 7357011);

    // balances are greater than before.
    let bal_carol = DiemAccount::balance<GAS>(@{{carol}});
    assert(bal_carol > bal_carol_old, 7357012);
  }
}
// check: EXECUTED
