//# init --parent-vasps Alice Bob
// Alice:     validators with 10M GAS
// Bob:   non-validators with  1M GAS

//# run --admin-script --signers DiemRoot Bob
script {
  
  use DiemFramework::Ancestry;
  use Std::Vector;
  use Std::Signer;
  use DiemFramework::Debug::print;
  fun main(diemroot: signer, bob: signer) {

    Ancestry::init(&bob, &diemroot);
    let diem_addr = Signer::address_of(&diemroot);
    let bob_addr = Signer::address_of(&bob);
    print(&diem_addr);
    print(&bob_addr);
    
    let tree = Ancestry::get_tree(bob_addr);
    print(&tree);
    
    assert!(Vector::contains<address>(&tree, &diem_addr), 7357001);
    let (is_family, _) = Ancestry::is_family(diem_addr, bob_addr);
    print(&is_family);
    // if (is_)
    assert!(is_family, 7357002);

  }
}
// check: EXECUTED


