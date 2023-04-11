//# init --validators Alice --parent-vasps Bob
//#      --addresses Carol=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Carol=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7

// Initialize an end-user account for Carol with 0 GAS

//# run --signers DiemRoot
//#     --args @Carol
//#     -- 0x1::DiemAccount::test_harness_create_user


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
    // There should be no payment history for Alice, since that payment would have failed (intentionally silently).
    assert!(last_payment == 0, 7357001);
    assert!(cumu == 0, 7357002);
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
  // use DiemFramework::Debug::print;

  fun main(vm: signer, _: signer) {

    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Alice,
      @Carol, // CAN! receive balance
      5000000,
      x"",
      x"",
      &vm
    );

    let (_, las_val, cumu) = Receipts::read_receipt(@Alice, @Carol);
    // print(&las_val);
    assert!(las_val== 5000000, 7357003);
    assert!(cumu== 5000000, 7357004);
  }
}
// check: EXECUTED