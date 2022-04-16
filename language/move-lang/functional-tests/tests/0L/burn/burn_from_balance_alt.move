//! account: alice, 10000000GAS, 0, validator

//! new-transaction
//! sender: diemroot
script {
  use 0x1::GAS::GAS;
  use 0x1::Diem;
  use 0x1::DiemAccount;
  use 0x1::Debug::print;
    
  fun main(vm: signer) {
    let cap = Diem::market_cap<GAS>();
    print(&cap);
    let prev_bal = DiemAccount::balance<GAS>(@{{alice}});
    print(&prev_bal);

    // assert(cap == bal, 735701);

    let burn_amount = 1000000;
    DiemAccount::vm_burn_from_balance<GAS>(
        @{{alice}},
        burn_amount,
        b"burn",
        &vm,
      );      
    let cap_later = Diem::market_cap<GAS>();
    print(&cap_later);
    let bal = DiemAccount::balance<GAS>(@{{alice}});
    print(&bal);
    assert(bal == (prev_bal - burn_amount), 735702);
    assert(cap_later == (cap - (burn_amount as u128)), 735703);
  }
}

// check: BurnEvent
// check: "Keep(EXECUTED)"