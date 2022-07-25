//# init --parent-vasps Alice Bob X Carol
// Alice, X:       validators with 10M GAS
// Bob, Carol: non-validators with  1M GAS

//# run --admin-script --signers DiemRoot Bob
script {
  use DiemFramework::Ancestry;
  use Std::Vector;
  use Std::Signer;

  fun main(vm: signer, bob_sig: signer) {
    Ancestry::migrate(&vm, &bob_sig, Vector::singleton(@Carol));
    let tree = Ancestry::get_tree(Signer::address_of(&bob_sig));
    assert!(Vector::contains<address>(&tree, &@Carol), 7357001);
  }
}
// check: EXECUTED