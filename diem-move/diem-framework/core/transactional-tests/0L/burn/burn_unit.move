//! account: alice, 2000000GAS, 0, validator
//! account: bob, 1000000GAS
//! account: carol, 1000000GAS

//! new-transaction
//! sender: bob
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}

// check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::GAS::GAS;
    use Std::Signer;
    use DiemFramework::DiemAccount;

    fun main(sender: signer) {
      Wallet::set_comm(&sender);
      let bal = DiemAccount::balance<GAS>(Signer::address_of(&sender));
      DiemAccount::init_cumulative_deposits(&sender, bal);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 2, 7357002);
    }
}

// // check: EXECUTED

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Burn;
  use Std::Vector;
  use Std::FixedPoint32;

  fun main(vm: signer) {
    // send to community wallet Bob
    DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Bob, 100000, x"", x"", &vm);
    // send to community wallet Carol
    DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Carol, 600000, x"", x"", &vm);

    let bal_bob_old = DiemAccount::balance<GAS>(@Bob);

    assert!(bal_bob_old == 1100000, 7357003);
    let bal_carol_old = DiemAccount::balance<GAS>(@Carol);

    assert!(bal_carol_old == 1600000, 7357004);

    Burn::reset_ratios(&vm);
    let (addr, _ , ratios) = Burn::get_ratios();
    assert!(Vector::length(&addr) == 2, 7357005);

    let carol_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
    let pct_carol = FixedPoint32::multiply_u64(100, carol_mult);
    // ratio for carol's community wallet.
    assert!(pct_carol == 59, 7357006);

    Burn::epoch_start_burn(&vm, @Alice, 100000);

    let bal_alice = DiemAccount::balance<GAS>(@Alice);
    assert!(bal_alice == 1200000, 7357007); // rounding issues
    
    // unchanged balance
    let bal_bob = DiemAccount::balance<GAS>(@Bob);
    assert!(bal_bob == bal_bob_old, 7357008);

    // unchanged balance

    let bal_carol = DiemAccount::balance<GAS>(@Carol);
    assert!(bal_carol == bal_carol_old, 7357009);
  }
}
// check: EXECUTED


//! new-transaction
//! sender: alice
script {
  use DiemFramework::Burn;

  fun main(alice: signer) {

    Burn::set_send_community(&alice);
  }
}
//////// SETS community send

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Burn;

  fun main(vm: signer) {
    let bal_bob_old = DiemAccount::balance<GAS>(@Bob);
    let bal_carol_old = DiemAccount::balance<GAS>(@Carol);

    // this time alice changed burn settings, and is resending to community.
    Burn::epoch_start_burn(&vm, @Alice, 100000);

    let bal_alice = DiemAccount::balance<GAS>(@Alice);
    assert!(bal_alice == 1100001, 7357010); // rounding issues
    
    // balances are greater than before.
    let bal_bob = DiemAccount::balance<GAS>(@Bob);
    assert!(bal_bob > bal_bob_old, 7357011);

    // balances are greater than before.
    let bal_carol = DiemAccount::balance<GAS>(@Carol);
    assert!(bal_carol > bal_carol_old, 7357012);
  }
}
// check: EXECUTED
