// These are manual inserts which are added since automatic inserts are
// not working (See issue #31)
// Insert into data struct

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
        Stats::insert({{bob}}, 2, 4);

    }
}
// check: EXECUTED
