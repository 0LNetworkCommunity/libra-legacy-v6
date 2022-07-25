//# init --parent-vasps Alice Bob
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS

// TODO: Unsure how to send a tx so that both alice and bob are signers. 
//       Testsuite only seems to allow diemroot and another signer.

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Ancestry;
  use Std::Vector;
  use Std::Signer;

  fun main(alice: signer, bob: signer) {
    Ancestry::init(&alice, &bob);
    let tree = Ancestry::get_tree(Signer::address_of(&alice));
    assert!(Vector::contains<address>(&tree, &Signer::address_of(&bob)), 7357001);
  }
}