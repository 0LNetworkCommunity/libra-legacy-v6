//# init --validators Alice

//# run --admin-script --signers DiemRoot DiemRoot
script {
  use DiemFramework::GAS::GAS;
  use DiemFramework::Diem;
  use DiemFramework::DiemAccount;
  // use DiemFramework::Debug::print;

  fun main(vm: signer, _: signer) {
    let cap = Diem::market_cap<GAS>();
    // print(&cap);
    let prev_bal = DiemAccount::balance<GAS>(@Alice);
    // print(&prev_bal);

    // assert!(cap == bal, 735701);

    let burn_amount = 1000000;    
    DiemAccount::vm_burn_from_balance<GAS>(
        @Alice,
        burn_amount,
        b"burn",
        &vm,
    );
    let cap_later = Diem::market_cap<GAS>();
    // print(&cap_later);
    let bal = DiemAccount::balance<GAS>(@Alice);
    // print(&bal);
    assert!(bal == (prev_bal - burn_amount), 735702);
    assert!(cap_later == (cap - (burn_amount as u128)), 735703);
  }
}