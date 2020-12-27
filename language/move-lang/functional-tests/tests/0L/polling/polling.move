//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0

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

// Bob votes "nay"
//! new-transaction
//! sender: bob
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // bob's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, false);

      // Check that Bob's vote was recorded and that voting is still open
      assert(Polling::get_no_votes({{alice}}) == 1, 73570001);
      assert(Polling::current_tally_is_no({{alice}}), 73570002);
      assert(Polling::get_result_is_final({{alice}}) == false, 73570003);
    }
}
// check: EXECUTED

// Carol votes "aye"
//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // carol's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, true);

      // Check that Carol's vote was recorded and that voting is still open
      assert(Polling::get_yes_votes({{alice}}) == 1, 73570004);
      assert(Polling::get_no_votes({{alice}}) == 1, 73570005);
      assert(Polling::get_result_is_final({{alice}}) == false, 73570006);
    }
}
// check: EXECUTED

// Carol calls for the vote to be tallied. This should fail because Carol is not the owner of the module
//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // carol's signer type added in tx.
      
      Polling::tally(sender, {{alice}});

      // Tally should have failed because Carol doesn't own the module (is not the "surveyor")
      assert(Polling::get_result_is_final({{alice}}) == false, 73570007);
    }
}
// check: EXECUTED

// Eve votes "nay". But Eve is not a validator so her vote should be ignored
//! new-transaction
//! sender: eve
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // eve's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, false);

      // Check that Eve's vote was *not* recorded and that voting is still open
      assert(Polling::get_yes_votes({{alice}}) == 1, 73570002);
      assert(Polling::get_no_votes({{alice}}) == 1, 73570002);
      assert(Polling::get_result_is_final({{alice}}) == false, 73570002);
    }
}
// check: EXECUTED

// Alice calls for the vote to be tallied
//! new-transaction
//! sender: alice
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // alice's signer type added in tx.
      
      Polling::tally(sender, {{alice}});

      assert(Polling::get_result_is_final({{alice}}) == true, 73570008);
      assert(Polling::current_tally_is_tie({{alice}}), 73570009);
    }
}
// check: EXECUTED

// Now Dave tries to vote. This should not affect the totals because the result has been finalized
//! new-transaction
//! sender: dave
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // dave's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, true);

      // Check that Dave's late vote did not change the result
      assert(Polling::get_result_is_final({{alice}}) == true, 73570010);
      assert(Polling::current_tally_is_tie({{alice}}), 73570011);
    }
}
// check: EXECUTED
