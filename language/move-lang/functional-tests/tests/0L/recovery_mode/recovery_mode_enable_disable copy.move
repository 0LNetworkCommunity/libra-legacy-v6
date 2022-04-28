//! account: alice, 1000000, 0, validator

// Tests the prologue reconfigures based on wall clock

//! block-prologue
//! proposer: alice
//! block-time: 1
//! round: 1

//! new-transaction
//! sender: diemroot

script {
    use 0x1::RecoveryMode;
    use 0x1::Vector;

    fun main(vm: signer){
      RecoveryMode::test_init_recovery(&vm, Vector::empty<address>(), 2);
      assert(RecoveryMode::is_recovery(), 7357001);
    }
}
// check: EXECUTED


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 61000000
//! round: 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////

//! new-transaction
//! sender: diemroot

script {
    use 0x1::RecoveryMode;
    use 0x1::Debug::print;

    fun main(_vm: signer){
      // RecoveryMode::test_init_recovery(&vm, Vector::empty<address>(), 2);
      // assert(RecoveryMode::is_recovery(), 7357001);
      print(&RecoveryMode::is_recovery());
    }
}
// check: EXECUTED


//////////////////////////////////////////////
///// Trigger second reconfiguration at 61*2 seconds ////
//! block-prologue
//! proposer: alice
//! block-time: 122000000
//! round: 30

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


//! new-transaction
//! sender: diemroot

script {
    use 0x1::RecoveryMode;
    // use 0x1::Debug::print;

    fun main(_vm: signer){
      // RecoveryMode::test_init_recovery(&vm, Vector::empty<address>(), 2);
      assert(!RecoveryMode::is_recovery(), 7357002);
      // print(&RecoveryMode::is_recovery());
    }
}
// check: EXECUTED
