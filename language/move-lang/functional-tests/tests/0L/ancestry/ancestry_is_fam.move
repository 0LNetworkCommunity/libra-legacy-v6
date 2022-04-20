

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0

//! new-transaction
//! sender: diemroot
//! execute-as: bob
script {
  
  use 0x1::Ancestry;
  use 0x1::Vector;
  use 0x1::Signer;
  use 0x1::Debug::print;
  fun main(diemroot: signer, bob: signer) {

    Ancestry::init(&bob, &diemroot);
    let diem_addr = Signer::address_of(&diemroot);
    let bob_addr = Signer::address_of(&bob);
    print(&diem_addr);
    print(&bob_addr);
    

    let tree = Ancestry::get_tree(bob_addr);
    print(&tree);
    
    assert(Vector::contains<address>(&tree, &diem_addr), 7357001);
    let (is_family, _) = Ancestry::is_family(diem_addr, bob_addr);
    print(&is_family);
    // if (is_)
    assert(is_family, 7357002);

  }
}
// check: EXECUTED


