//! account: alice, 1000000, 0, validator

// Tests the prologue reconfigures based on wall clock

//! block-prologue
//! proposer: alice
//! block-time: 1
//! round: 1


//! new-transaction
//! sender: diemroot
script {
    use 0x1::TowerState;
    // use 0x1::Debug::print;

    fun main(_sender: signer) {
        let (a, b) = TowerState::get_difficulty();
        // check the state started with the testnet defaults
        assert(a==100, 735701);
        assert(b==512, 735701);
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
    use 0x1::Debug::print;

    fun main(_sender: signer) {
        let (a, b) = TowerState::get_difficulty();
        // check the state started with the testnet defaults
        print(&a);
        print(&b);
    }
}
//check: EXECUTED