//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0

//! new-transaction
//! sender: diemroot
//! execute-as: bob
script {
  
  use 0x1::Ancestry;

  fun main(alice: signer, bob: signer) {

    Ancestry::init(&alice, &bob);
  }
}
// check: EXECUTED
