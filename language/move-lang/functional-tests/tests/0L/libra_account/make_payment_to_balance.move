//! account: alice, 1000GAS, 0, validator
//! account: bob, 0GAS

// Testing that payments cannot be attempted to accounts that do not receive the balance. Can cause network halt otherwise.

//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;

  fun main(vm: &signer) {
    // Does not fail when trying to make payment to an account which cannot receive balance.
    // fails silently, as asserts can cause the VM to halt.
    LibraAccount::make_payment<GAS>(
      {{alice}},
      0x0, // cannot receive balance
      100,
      x"",
      x"",
      vm
    );
  }
}
// check: EXECUTED


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraAccount;
  use 0x1::GAS::GAS;

  fun main(vm: &signer) {
    // Should be fine if the balance is 0
    LibraAccount::make_payment<GAS>(
      {{alice}},
      {{bob}}, // has a 0 in balance
      100,
      x"",
      x"",
      vm
    );
  }
}
// check: EXECUTED