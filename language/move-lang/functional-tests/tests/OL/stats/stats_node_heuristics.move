//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: charlie, 1000000
//! account: storage, 4000000

// insert is curently a public function. This is only for debugging purposes.
// inserts should implicitly happen every single change in blocks (i.e. new //! block-prologue)
// See issue #31 on GitHub for more details.

// Initialize
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

// These are manual inserts which are added since automatic inserts are
// not working (See issue #31)

// Insert into data struct
//! new-transaction
//! gas-price: 1
//! max-gas: 2000000
//! sender: storage
script {
    use 0x0::Stats;
    use 0x0::Debug;
    fun main(){
        Stats::insert({{bob}}, 0, 4);
        Stats::insert({{charlie}}, 4, 7);
        Stats::insert({{alice}}, 10, 19);
        Stats::insert({{alice}}, 120, 199);
        Stats::insert({{bob}}, 80, 149);
        let a = 1;
        Debug::print(&a);
    }
}
// check: EXECUTED

// Query data struct
//! new-transaction
//! sender: storage
script{
    use 0x0::Debug;
    use 0x0::Stats;
    fun main(){
        let a = Stats::Node_Heuristics({{alice}}, 0, 500);
        // Should print 90
        Debug::print(&a);
        a = Stats::Node_Heuristics({{alice}}, 0, 100);
        // Should print 10
        Debug::print(&a);
        a = Stats::Node_Heuristics({{bob}}, 0, 500);
        // Should print 75
        Debug::print(&a);
        a = Stats::Node_Heuristics({{bob}}, 0, 100);
        // Should print 25
        Debug::print(&a);
        a = Stats::Node_Heuristics({{charlie}}, 0, 500);
        // Should print 4
        Debug::print(&a);
        a = 3;
        Debug::print(&a);
    }
}
// check: EXECUTED
