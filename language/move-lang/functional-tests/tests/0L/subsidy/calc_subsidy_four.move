//! account: alice, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1

//! new-transaction
//! sender: diemroot
script {
  
  use 0x1::Subsidy;

  fun main(vm: signer) {
    // assumes no tx fees were paid
    let (total, unit) = Subsidy::calculate_subsidy(&vm, 4);
    assert(total == 296000000, 7357190101021000);
    assert(unit == 74000000, 7357190101021001);
  }
}
// check: EXECUTED
