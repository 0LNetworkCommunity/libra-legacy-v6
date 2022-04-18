//! account: alice, 1000000, 0, validator

// TODO: unsure how to send a tx so that both alice and bob are signers. Testsuite only seems to allow diemroot and another signer.

//! new-transaction
//! sender: alice
script {
  
  use 0x1::Vouch;
  // use 0x1::Signer;
  // use 0x1::Debug::print;
  fun main(alice: signer) {
    Vouch::init(&alice);
    assert(Vouch::is_init(@{{alice}}), 7347001);

  }
}
// check: EXECUTED
