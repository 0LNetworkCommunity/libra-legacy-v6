//! account: alice, 1000000GAS, 0, validator

// Check autopay is triggered in block prologue correctly i.e., middle of epoch

///////////////////////////////////////////////
///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 2000001
//! round: 1
//////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraTimestamp;
  use 0x1::AutoPay;
  fun main(vm: &signer) {
    let time = LibraTimestamp::now_seconds();
    assert(time == 2, 7357001);
    assert(AutoPay::tick(vm), 7357002);
  }
}
// check: EXECUTED

///////////////////////////////////////////////
///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 3000001
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING //////
// check: NewEpochEvent
//////////////////////////////////////////////
