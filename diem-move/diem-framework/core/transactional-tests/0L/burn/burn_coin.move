//# init --validators Alice

//! new-transaction
//! sender: diemroot
script {
  use DiemFramework::GAS::GAS;
  use DiemFramework::Diem;
    
  fun main(vm: signer) {
    let coin = Diem::mint<GAS>(&vm, 10);
    let cap = Diem::market_cap<GAS>();
    Diem::vm_burn_this_coin(&vm, coin);
    let cap_later = Diem::market_cap<GAS>();
    assert!(cap_later < cap, 735701);
  }
}

// check: BurnEvent
// check: "Keep(EXECUTED)"