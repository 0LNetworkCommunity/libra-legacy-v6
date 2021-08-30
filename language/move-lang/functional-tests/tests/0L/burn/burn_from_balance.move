//! account: alice, 1000000GAS, 0, validator

//! new-transaction
//! sender: diemroot
script {
  use 0x1::GAS::GAS;
  use 0x1::Diem;
  use 0x1::DiemAccount;
  use 0x1::Debug::print;
    
  fun main(vm: signer) {
    DiemAccount::vm_burn_from_balance<GAS>(
        @{{alice}},
        100000,
        b"burn",
        &vm,
      );      
    let cap_later = Diem::market_cap<GAS>();
    print(&cap_later);
    // assert(cap_later < cap, 735701);
  }
}

// check: BurnEvent
// check: "Keep(EXECUTED)"