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

    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Alice,
      @0x1, // can't receive balance, but fails silently
      100,
      x"",
      x"",
      &vm
    );
  }
}

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::DiemAccount;
  use DiemFramework::GAS::GAS;

  fun main(vm: signer, _: signer) {
    // Should be fine if can hold balance
    DiemAccount::vm_make_payment_no_limit<GAS>(
      @Alice,
      @Bob,
      100,
      x"",
      x"",
      &vm
    );
  }
}
