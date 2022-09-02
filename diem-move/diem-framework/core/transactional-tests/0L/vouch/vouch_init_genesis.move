//# init --validators Alice Bob

// TODO: Unsure how to send a tx so that both Alice and bob are signers. 
//       Testsuite only seems to allow diemroot and another signer.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Vouch;
  use Std::Vector;
  use Std::Signer;

  fun main(_dr: signer, bob_addr: signer) {
    assert!(Vouch::is_init(@Alice), 7347001);
    let includes = Vector::contains(
      &Vouch::get_buddies(@Alice), &Signer::address_of(&bob_addr)
    );
    assert!(includes, 7357002);
  }
}
