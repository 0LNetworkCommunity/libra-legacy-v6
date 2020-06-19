//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000
//! account: storage, 4000000

// insert is curently a public function. This is only for debugging purposes.
// inserts should implicitly happen every single change in blocks (i.e. new //! block-prologue)
// See issue #31 on GitHub for more details.

// Initialization done in Genesis

// These are manual inserts which are added since automatic inserts are
// not working (See issue #31)

// Insert into data struct
//! new-transaction
//! gas-price: 1
//! max-gas: 2000000
//! sender: storage
script {
    use 0x0::Stats;
    fun main(){
        Stats::insert({{bob}}, 0, 4);
        Stats::insert({{charlie}}, 4, 7);
        Stats::insert({{alice}}, 4, 4);
        Stats::insert({{alice}}, 10, 19);
        Stats::insert({{alice}}, 90, 119);
        Stats::insert({{bob}}, 80, 104);
        Stats::insert({{bob}}, 120, 129);
    }
}
// check: EXECUTED