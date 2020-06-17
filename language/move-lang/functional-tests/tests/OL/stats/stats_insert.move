// These are manual inserts which are added since automatic inserts are
// not working (See issue #31)
// Insert into data struct

// Initialize
//! new-transaction
//! sender: association
script {
    use 0x0::Stats;
    use 0x0::Debug;
    use 0x0::Transaction;
    
        fun main(account: &signer) {
            let success = Stats::initialize(account);
            Transaction::assert(success == 1u64, 1);
            // let a = 0;
            Debug::print(&success);
        }
    }
// check: EXECUTED

//! new-transaction
//! gas-price: 1
//! max-gas: 2000000
//! sender: storage
//! account: bob, 1000000, 0, validator
//! account: storage, 4000000

script {
    use 0x0::Stats;
    // use 0x0::Debug;
    fun main(){
        //Stats::initialize(account);
        Stats::insert({{bob}}, 2, 4);

    }
}
// check: EXECUTED
