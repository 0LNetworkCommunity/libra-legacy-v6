//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::GAS::GAS;
  use DiemFramework::Diem;
  use DiemFramework::DiemAccount;
    
  fun main(vm: signer, _: signer) {
    let cap = Diem::market_cap<GAS>();
    DiemAccount::vm_burn_from_balance<GAS>(
        @Alice,
        100000,
        b"burn",
        &vm,
      );      
    let cap_later = Diem::market_cap<GAS>();
    assert!(cap_later < cap, 735701);
  }
}
// check: BurnEvent
// check: "Keep(EXECUTED)"