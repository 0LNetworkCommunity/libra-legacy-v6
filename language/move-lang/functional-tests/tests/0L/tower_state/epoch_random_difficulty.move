//! account: alice, 100000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator


//! block-prologue
//! proposer: alice
//! block-time: 1
//! round: 1


//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;

    fun main(_sender: signer) {
        let (diff, sec) = TowerState::get_difficulty();
        // check the state started with the testnet defaults
        assert(diff==100, 735701);
        assert(sec==512, 735702);
    }
}
//check: EXECUTED


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
    use 0x1::TowerState;
    // use 0x1::Debug::print;

    fun main(_sender: signer) {
        let (diff, sec) = TowerState::get_difficulty();
        // print(&diff);
        // check the state started with the testnet defaults
        assert(diff==332, 735703);
        assert(sec==512, 735704);

    }
}
//check: EXECUTED