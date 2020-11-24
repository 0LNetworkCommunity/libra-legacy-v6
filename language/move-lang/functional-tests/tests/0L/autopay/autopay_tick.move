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
//! block-time: 45000000
//! round: 20
//////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraTimestamp;
  use 0x1::AutoPay;
  fun main(vm: &signer) {
    let time = LibraTimestamp::now_seconds();
    assert(time == 45, 7357004);
    assert(!AutoPay::tick(vm), 7357005);
  }
}
// check: EXECUTED


///////////////////////////////////////////////
///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 30

///// TEST RECONFIGURATION IS HAPPENING //////
// check: NewEpochEvent
//////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraTimestamp;
  use 0x1::AutoPay;
  fun main(vm: &signer) {
    let time = LibraTimestamp::now_seconds();
    assert(time == 61, 7357006);
    assert(!AutoPay::tick(vm), 7357007);
  }
}
// check: EXECUTED


///////////////////////////////////////////////
///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 75000000
//! round: 40
//////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraTimestamp;
  use 0x1::AutoPay;
  fun main(vm: &signer) {
    let time = LibraTimestamp::now_seconds();
    assert(time == 75, 7357008);
    assert(!AutoPay::tick(vm), 7357009);
  }
}
// check: EXECUTED


///////////////////////////////////////////////
///// Trigger Autopay Tick at 0.5 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 92000000
//! round: 50
//////////////////////////////////////////////


//! new-transaction
//! sender: libraroot
script {
  use 0x1::LibraTimestamp;
  use 0x1::AutoPay;
  fun main(vm: &signer) {
    let time = LibraTimestamp::now_seconds();
    assert(time == 92, 7357010);
    assert(AutoPay::tick(vm), 7357011);
  }
}
// check: EXECUTED
