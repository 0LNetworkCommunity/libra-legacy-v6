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

// check: EXECUTED

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
    DiemAccount::vm_make_payment_no_limit<GAS>(@Alice, @Carol, 900000, x"", x"", &vm);

    Burn::reset_ratios(&vm);
    let (addr, deps , ratios) = Burn::get_ratios();
    assert!(Vector::length(&addr) == 2, 7357003);
    assert!(Vector::length(&deps) == 2, 7357004);
    assert!(Vector::length(&ratios) == 2, 7357005);

    let bob_deposits_indexed = *Vector::borrow<u64>(&deps, 0);
    // print(&bob_deposits_indexed);
    assert!(bob_deposits_indexed == 1100500, 7357006);
    let carol_deposits_indexed = *Vector::borrow<u64>(&deps, 1);
    assert!(carol_deposits_indexed == 1904500, 7357007);

    let bob_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 0);
    let pct_bob = FixedPoint32::multiply_u64(100, bob_mult);
    // print(&pct_bob);
    // ratio for bob's community wallet.
    assert!(pct_bob == 36, 7357008);

    let carol_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
    let pct_carol = FixedPoint32::multiply_u64(100, carol_mult);
    // print(&pct_carol);
    // ratio for carol's community wallet.
    assert!(pct_carol == 63, 7357009);
  }
}
// check: EXECUTED

