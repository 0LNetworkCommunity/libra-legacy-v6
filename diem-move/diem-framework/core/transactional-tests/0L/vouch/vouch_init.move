//# init --validators Alice Bob

// TODO: Unsure how to send a tx so that both alice and bob are signers. 
//       Testsuite only seems to allow diemroot and another signer.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Vouch;

  fun main(_dr: signer, alice: signer) {
    Vouch::init(&alice);
    assert!(Vouch::is_init(@Alice), 7347001);
  }
}

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Vouch;
  use Std::Vector;
  use Std::Signer;

  fun main(_dr: signer, bob: signer) {
    assert!(Vouch::is_init(@Alice), 7347002);
    Vouch::vouch_for(&bob, @Alice);
    let includes = Vector::contains(
      &Vouch::get_buddies(@Alice), &Signer::address_of(&bob)
    );
    assert!(includes, 7357003);
  }
}

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Vouch;
  use Std::Vector;
  use Std::Signer;

  fun main(_dr: signer, bob: signer) {
    assert!(Vouch::is_init(@Alice), 7347004);
    Vouch::revoke(&bob, @Alice);

    let includes = Vector::contains(
      &Vouch::get_buddies(@Alice), &Signer::address_of(&bob)
    );

    assert!(!includes, 7357005);
  }
}