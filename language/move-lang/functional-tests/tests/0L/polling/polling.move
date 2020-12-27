//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0
//! account: carol, 1000000, 0

// The data will be initialized and operated all through alice's account

// Alice creates a new poll
//! new-transaction
//! sender: alice
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // alice's signer type added in tx.
      
      Polling::initialize(sender);
    }
}
// check: EXECUTED

// Bob votes "aye"
//! new-transaction
//! sender: bob
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // bob's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, true, 100);

      //assert(Polling::yes_votes({{alice}}) == 1, 73570002);
    }
}
// check: EXECUTED

// Carol votes "nay"
//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // carol's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, false, 200);
    }
}
// check: EXECUTED

// Carol calls for the vote to be tallied
//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(){ // carol's signer type added in tx.
      
      assert(!Polling::tally({{alice}}), 73570002);
    }
}
// check: EXECUTED