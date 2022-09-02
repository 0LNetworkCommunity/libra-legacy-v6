//# init --validators Alice Bob Carol

// TODO: Unsure how to send a tx so that both Alice and bob are signers. 
//       Testsuite only seems to allow diemroot and another signer.

//# run --admin-script --signers DiemRoot Alice
script {
  use DiemFramework::Vouch;
  use Std::Vector;

  fun main(_dr: signer, _bob_addr: signer) {
    assert!(Vouch::is_init(@Alice), 7347001);
    let includes = Vector::contains(
      &Vouch::get_buddies(@Alice), &@Bob);
    assert!(includes, 7357002);
  }
}
