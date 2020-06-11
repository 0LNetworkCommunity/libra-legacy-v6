//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie
//! account: storage, 1000000

//! new-transaction
//! sender: storage
script {
    use 0x0::Stats;
    use 0x0::Debug;
        fun main() {
            Stats::initialize();
            let a = 10000;
            Debug::print(&a);
        }
    }
// check: EXECUTED
    
//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount;
    use 0x0::LBR;
    fun main(account: &signer){
        LibraAccount::pay_from<LBR::T>(account, {{alice}}, 100);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 2

//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount;
    use 0x0::LBR;
    fun main(account: &signer){
        LibraAccount::pay_from<LBR::T>(account, {{bob}}, 1000);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount;
    use 0x0::LBR;
    fun main(account: &signer){
        LibraAccount::pay_from<LBR::T>(account, {{alice}}, 50);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: alice
//! block-time: 4

//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount;
    use 0x0::LBR;
    fun main(account: &signer){
        LibraAccount::pay_from<LBR::T>(account, {{charlie}}, 80);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 5

// The below transactions error out and get discarded for some reason
// //! new-transaction
// //! gas-price: 1
// //! max-gas: 10000000
// //! sender: storage
// script {
//     use 0x0::Stats;
//     fun main(){
//         Stats::insert({{bob}}, 2, 2);
//     }
// }
// // check: EXECUTED

// //! new-transaction
// //! gas-price: 1
// //! max-gas: 10000000
// //! sender: storage
// script {
//     use 0x0::Stats;
//     fun main(){
//         Stats::insert({{charlie}}, 1, 1);
//     }
// }
// // check: EXECUTED


// These (below) currently all print zero. This should not be the case, but it seems
// every transaction which tries to insert into the data structure becomes
// discarded or runs out of gas. Possibly too expensive.

//! new-transaction
//! sender: storage
script {
    use 0x0::Debug;
    use 0x0::Stats;
    fun main(){
        let a = Stats::Node_Heuristics({{alice}}, 0, 500);
        Debug::print(&a);
        a = Stats::Node_Heuristics({{alice}}, 0, 100);
        Debug::print(&a);
        a = Stats::Node_Heuristics({{bob}}, 0, 500);
        Debug::print(&a);
        a = Stats::Node_Heuristics({{bob}}, 0, 200);
        Debug::print(&a);
        a = Stats::Node_Heuristics({{charlie}}, 0, 500);
        Debug::print(&a);
    }
}
// check: EXECUTED
