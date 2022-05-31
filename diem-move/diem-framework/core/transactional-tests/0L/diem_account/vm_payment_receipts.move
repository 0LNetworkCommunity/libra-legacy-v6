//# init --parent-vasps Alice Bob
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS

// Testing that payments cannot be attempted to accounts that do not
// receive the balance. Can cause network halt otherwise.

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Receipts;

  fun main(vm: signer, _: signer) {
    // Does not fail when trying to make payment to an account which cannot
    // receive balance. Fails silently, as asserts can cause the VM to halt.
    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Alice,
      @Bob, // cannot receive balance
      1000000,
      x"",
      x"",
      &vm
    );

    let (_, last_payment, cumu) = Receipts::read_receipt(@Alice, @Bob);
      // todo: last_payment, cumu are both 0
    assert!(last_payment == 1000000, 1);
    assert!(cumu == 2000000, 2);
  }
}
// check: EXECUTED


//# block --proposer Alice --time 1234 --round 0

//TODO: Timestamps are not showing up in Move tests

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;
  use DiemFramework::Receipts;

  fun main(vm: signer, _: signer) {
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