//! account: alice, 1000000, 0, empty, validator
//! account: bob, 1000000, 0, empty, validator
//! account: charlie
//! account: storage, 1000000

//! new-transaction
//! sender: storage
script {
    use 0x0::Stats;
        fun main() {
            Stats::initialize();
        }
    }
// check: EXECUTED
    
//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount;
    fun main(){
        let coin = LibraAccount::withdraw_from_sender<LBR::T>(100);
        LibraAccount::deposit({{alice}}, coin);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 2

//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount
    fun main(){
        let coin = LibraAccount::withdraw_from_sender<LBR::T>(100);
        LibraAccount::deposit({{bob}}, coin);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount
    fun main(){
        let coin = LibraAccount::withdraw_from_sender<LBR::T>(100);
        LibraAccount::deposit({{alice}}, coin);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 4

//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount
    fun main(){
        let coin = LibraAccount::withdraw_from_sender<LBR::T>(100);
        LibraAccount::deposit({{charlie}}, coin);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 5

//! new-transaction
//! sender: storage
script {
    use 0x0::Debug;
    use 0x0::Stats;
    fun main(){
        Debug::print(Stats::Node_Heuristics({{alice}}, 0, 5));
        Debug::print(Stats::Node_Heuristics({{alice}}, 0, 1));
        Debug::print(Stats::Node_Heuristics({{bob}}, 0, 5));
        Debug::print(Stats::Node_Heuristics({{bob}}, 0, 2));
        Debug::print(Stats::Node_Heuristics({{charlie}}, 0, 5));
    }
}
// check: EXECUTED
