//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0
//! account: carol, 1000000, 0

// The data will be initialized and operated all through alice's account

//! new-transaction
//! sender: alice
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // alice's signer type added in tx.
      
      Polling::initialize(sender);

      // Polling::vote(sender, true, 100);

      // assert(Polling::contains(sender, 1), 73570002);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: bob
script {
    use 0x42::Polling;
    fun main(){ // bob's signer type added in tx.
      
      Polling::vote({{alice}}, true, 100);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(){ // carol's signer type added in tx.
      
      Polling::vote({{alice}}, false, 200);
    }
}
// check: EXECUTED

//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(){ // carol's signer type added in tx.
      
      assert(!Polling::tally({{alice}}), 73570002);
    }
}
// check: EXECUTED