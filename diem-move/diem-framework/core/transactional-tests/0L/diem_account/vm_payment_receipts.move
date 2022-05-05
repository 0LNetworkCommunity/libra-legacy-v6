//! account: alice, 10000000GAS, 0, validator
//! account: bob, 0GAS

// Testing that payments cannot be attempted to accounts that do not receive the balance. Can cause network halt otherwise.

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Receipts;

  fun main(vm: signer) {
    // Does not fail when trying to make payment to an account which cannot receive balance.
    // fails silently, as asserts can cause the VM to halt.
    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Alice,
      @Bob, // cannot receive balance
      1000000,
      x"",
      x"",
      &vm
    );

    let (_, las_val, cumu) = Receipts::read_receipt(@Alice, @Bob);
    assert!(las_val== 1000000, 1);
    assert!(cumu== 1000000, 2);
  }
}
// check: EXECUTED


//! block-prologue
//! proposer: alice
//! block-time: 1234

//TODO: Timestamps are not showing up in Move tests

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Receipts;

  fun main(vm: signer) {
    // Does not fail when trying to make payment to an account which cannot receive balance.
    // fails silently, as asserts can cause the VM to halt.
    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Alice,
      @Bob, // cannot receive balance
      5000000,
      x"",
      x"",
      &vm
    );

    let (_, las_val, cumu) = Receipts::read_receipt(@Alice, @Bob);
    assert!(las_val== 5000000, 3);
    assert!(cumu== 6000000, 4);
  }
}
// check: EXECUTED