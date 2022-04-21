//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0
//! account: carol, 10000000, 0

//! new-transaction
//! sender: diemroot
//! execute-as: bob
script {
  
  use 0x1::Ancestry;
  use 0x1::Vector;
  use 0x1::Signer;

  fun main(vm: signer, bob_sig: signer) {

    Ancestry::migrate(&vm, &bob_sig, Vector::singleton(@{{carol}}));

    let tree = Ancestry::get_tree(Signer::address_of(&bob_sig));

    assert(Vector::contains<address>(&tree, &@{{carol}}), 7357001);

  }
}
// check: EXECUTED
