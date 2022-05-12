//# init --validators Alice
//#      --addresses Bob=0x4b7653f6566a52c9b496f245628a69a0
//#      --private-keys Bob=f5fd1521bd82454a9834ef977c389a0201f9525b11520334842ab73d2dcbf8b7

// Testing that payments cannot be attempted to accounts that do not
// receive the balance. Can cause network halt otherwise.

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(vm: signer, _: signer) {
    // Does not fail when trying to make payment to an account which cannot receive balance.
    // fails silently, as asserts can cause the VM to halt.
    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Alice,
      @0x0, // cannot receive balance
      100,
      x"",
      x"",
      &vm
    );
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(vm: signer, _: signer) {
    // Should be fine if the balance is 0
    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Alice,
      @Bob, // has a 0 in balance
      100,
      x"",
      x"",
      &vm
    );
  }
}
// check: EXECUTED