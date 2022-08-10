//# init --validators Alice Bob Carol Dave Eve Frank
// Validators with 10M GAS

// TODO: Unsure how to send a tx so that both Alice and bob are signers. 
//       Testsuite only seems to allow diemroot and another signer.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Vouch;
  // use Std::Signer;
  // use DiemFramework::Debug::print;
  fun main(_dr: signer, Alice: signer) {
    Vouch::init(&Alice);
    assert!(Vouch::is_init(@Alice), 7347001);

  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Vouch;
  use Std::Vector;
  use Std::Signer;

  fun main(_dr: signer, bob: signer) {
    assert!(Vouch::is_init(@Alice), 7347002);
    Vouch::vouch_for(&bob, @Alice);

    let includes = Vector::contains(
      &Vouch::get_buddies(@Alice), 
      &Signer::address_of(&bob)
    );

    assert!(includes, 7357003);
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Carol
script {
  use DiemFramework::Vouch;
  use Std::Vector;
  use Std::Signer;

  fun main(_dr: signer, Carol_sig: signer) {
    assert!(Vouch::is_init(@Alice), 7347004);

    Vouch::vouch_for(&Carol_sig, @Alice);
    let includes = Vector::contains(
      &Vouch::get_buddies(@Alice), &Signer::address_of(&Carol_sig)
    );

    assert!(includes, 7357005);
  }
}
// check: EXECUTED

//# run --admin-script --signers DiemRoot Dave
script {
  use DiemFramework::Vouch;
  use Std::Vector;
  use Std::Signer;

  fun main(_dr: signer, dave_sig: signer) {
    assert!(Vouch::is_init(@Alice), 7347006);
    Vouch::vouch_for(&dave_sig, @Alice);

    let includes = Vector::contains(
      &Vouch::get_buddies(@Alice), 
      &Signer::address_of(&dave_sig)
    );
    assert!(includes, 7357007);
    let unrelated = Vouch::unrelated_buddies(@Alice);
    assert!(Vector::length(&unrelated) == 3, 7357008);
  }
}
// check: EXECUTED