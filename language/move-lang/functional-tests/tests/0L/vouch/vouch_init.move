//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator

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


//! new-transaction
//! sender: bob
script {
  
  use 0x1::Vouch;
  use 0x1::Vector;
  use 0x1::Signer;
  fun main(bob: signer) {
    assert(Vouch::is_init(@{{alice}}), 7347002);

    Vouch::vouch_for(&bob, @{{alice}});

    let includes = Vector::contains(&Vouch::get_buddies(@{{alice}}), &Signer::address_of(&bob));

    assert(includes, 7357003);
  }
}
// check: EXECUTED