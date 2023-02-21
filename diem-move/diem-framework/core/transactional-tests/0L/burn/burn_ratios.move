//# init --validators Alice Bob Carol

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::DiemAccount;

    fun main(_dr:signer, sender: signer) {
      Wallet::set_comm(&sender);
      // start with tracker at 0
      DiemAccount::init_cumulative_deposits(&sender, 0);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 1, 7357001);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::Wallet;
    use Std::Vector;
    use DiemFramework::DiemAccount;

    fun main(_dr:signer, sender: signer) {
      Wallet::set_comm(&sender);
      // start with tracker at 0
      DiemAccount::init_cumulative_deposits(&sender, 0);
      let list = Wallet::get_comm_list();
      assert!(Vector::length(&list) == 2, 7357002);
    }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Burn;
  use Std::Vector;
  use Std::FixedPoint32;
  use DiemFramework::Debug::print;

  fun main(vm: signer, _:signer) {
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
    print(&bob_deposits_indexed);
    assert!(bob_deposits_indexed == 100500, 7357006);
    let carol_deposits_indexed = *Vector::borrow<u64>(&deps, 1);
    print(&carol_deposits_indexed);
    assert!(carol_deposits_indexed == 904500, 7357007);

    let bob_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 0);
    let pct_bob = FixedPoint32::multiply_u64(100, bob_mult);
    print(&pct_bob);
    // ratio for bob's community wallet.
    assert!(pct_bob == 9, 7357008); // todo

    let carol_mult = *Vector::borrow<FixedPoint32::FixedPoint32>(&ratios, 1);
    let pct_carol = FixedPoint32::multiply_u64(100, carol_mult);
    // ratio for carol's community wallet.
    print(&pct_carol);
    assert!(pct_carol == 89, 7357009); // todo
  }
}
// check: EXECUTED

