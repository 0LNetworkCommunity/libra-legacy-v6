//! account: alice, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: diemroot
script {
  
  use 0x1::Teams;

  fun main(vm: signer) {
    // assumes no tx fees were paid
    Teams::vm_init(&vm);
    assert(Teams::vm_is_init(), 0);
  }
}
// check: EXECUTED
