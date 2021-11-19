//! account: alice, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: diemroot
script {
  
  use 0x1::Delegation;

  fun main(vm: signer) {
    // assumes no tx fees were paid
    Delegation::vm_init(&vm);
  }
}
// check: EXECUTED
