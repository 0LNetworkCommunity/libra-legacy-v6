//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000
//! account: storage, 4000000

// The data struct and history are all kept in storage's account.
// For now, any inserts and/or queries have to be in transactions sent
// by storage account.

// Also, insert is curently a public function. This is only for debugging purposes.

// Also, inserts implicitly happen every single change in blocks (i.e. new //! block-prologue)
// However, since inserts are currently failing, nothing actually gets changed in the DS.

//! new-transaction
//! sender: association
script {
    use 0x0::Stats;
    use 0x0::Debug;
        fun main(account: &signer) {
            Stats::initialize(account);
            let a = 0;
            Debug::print(&a);
        }
    }
// check: EXECUTED

//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount;
    use 0x0::LBR;
    use 0x0::Debug;
    fun main(account: &signer){
        LibraAccount::pay_from<LBR::T>(account, {{alice}}, 100);
        let a = 1;
        Debug::print(&a);
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
    use 0x0::Debug;
    fun main(account: &signer){
        LibraAccount::pay_from<LBR::T>(account, {{bob}}, 1000);
        let a = 2;
        Debug::print(&a);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: storage
script {
    use 0x0::LibraAccount;
    use 0x0::LBR;
    use 0x0::Debug;
    fun main(account: &signer){
        LibraAccount::pay_from<LBR::T>(account, {{alice}}, 50);
        let a = 3;
        Debug::print(&a);
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
    use 0x0::Debug;
    fun main(account: &signer){
        LibraAccount::pay_from<LBR::T>(account, {{charlie}}, 80);
        let a = 4;
        Debug::print(&a);
    }
}
// check: EXECUTED

//! block-prologue
//! proposer: bob
//! block-time: 5

// The below transactions error out and get discarded for some reason.
// These are manual inserts I added for debugging.
//! new-transaction
//! gas-price: 1
//! max-gas: 2000000
//! sender: storage
script {
    use 0x0::Stats;
    use 0x0::Debug;
    fun main(){
        Stats::insert({{bob}}, 2, 2);
        let a = 5;
        Debug::print(&a);
    }
}
// check: EXECUTED
