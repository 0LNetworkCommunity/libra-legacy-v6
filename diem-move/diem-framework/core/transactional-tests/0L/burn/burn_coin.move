//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::GAS::GAS;
  use DiemFramework::Diem;
    
  fun main(vm: signer, _account: signer) {
    let coin = Diem::mint<GAS>(&vm, 10);
    let cap = Diem::market_cap<GAS>();
    Diem::vm_burn_this_coin(&vm, coin);
    let cap_later = Diem::market_cap<GAS>();
    assert!(cap_later < cap, 735701);
  }
}
// check: BurnEvent
// check: "Keep(EXECUTED)"