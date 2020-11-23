//! account: alice, 1000000GAS, 0, validator

// Check autopay is triggered in block prologue correctly i.e., middle of epoch

///////////////////////////////////////////////
///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 31000000
//! round: 1
//////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraTimestamp;
  use 0x1::AutoPay;
  fun main(vm: &signer) {
    let time = LibraTimestamp::now_seconds();
    assert(time == 31, 7357001);
    assert(AutoPay::tick(vm), 7357002);
  }
}
// check: EXECUTED

///////////////////////////////////////////////
///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 60000000
//! round: 

///// TEST RECONFIGURATION IS HAPPENING //////
// check: NewEpochEvent
//////////////////////////////////////////////
