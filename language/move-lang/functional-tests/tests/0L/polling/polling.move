//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0, validator
//! account: dave, 1000000, 0, validator
//! account: eve, 1000000, 0

// The data will be initialized and operated all through alice's account

// Alice initializes the polling contract
//! new-transaction
//! sender: alice
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // alice's signer type added in tx.
      
      Polling::initialize(sender);
    }
}
// check: EXECUTED

// Bob creates a poll with index "0" and votes "nay"
//! new-transaction
//! sender: bob
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // bob's signer type added in tx.
      
      let poll_index = Polling::create_poll(sender, {{alice}});
      assert(poll_index == 0, 73570000);

      Polling::vote(sender, {{alice}}, 0, false);

      // Check that Bob's vote was recorded and that voting is still open
      let (yes, no) = Polling::get_tally({{alice}}, 0);
      assert(yes == 0, 73570001);
      assert(no == 1, 73570001);
      assert(Polling::get_result_is_final({{alice}}, 0) == false, 73570003);
    }
}
// check: EXECUTED

// Carol votes "aye"
//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // carol's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, 0, true);

      // Check that Carol's vote was recorded and that voting is still open
      let (yes, no) = Polling::get_tally({{alice}}, 0);
      assert(yes == 1, 73570001);
      assert(no == 1, 73570001);
      assert(Polling::get_result_is_final({{alice}}, 0) == false, 73570006);
    }
}
// check: EXECUTED

// Carol calls for the vote to be tallied. This should fail because Carol is not the creator of the poll (Bob is)
//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // carol's signer type added in tx.
      
      Polling::tally(sender, {{alice}}, 0);

      // Tally should have failed because Carol doesn't own the module (is not the "surveyor")
      assert(Polling::get_result_is_final({{alice}}, 0) == false, 73570007);
    }
}
// check: EXECUTED

// Eve votes "nay". But Eve is not a validator so her vote should be ignored
//! new-transaction
//! sender: eve
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // eve's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, 0, false);

      // Check that Eve's vote was *not* recorded and that voting is still open
      let (yes, no) = Polling::get_tally({{alice}}, 0);
      assert(yes == 1, 73570001);
      assert(no == 1, 73570001);
      assert(Polling::get_result_is_final({{alice}}, 0) == false, 73570002);
    }
}
// check: EXECUTED

// Bob calls for the vote to be tallied. This should succeed because Bob is the creator of the poll
//! new-transaction
//! sender: bob
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // bob's signer type added in tx.
      
      Polling::tally(sender, {{alice}}, 0);

      let (yes, no) = Polling::get_tally({{alice}}, 0);
      assert(yes == 1, 73570001);
      assert(no == 1, 73570001);
      assert(Polling::get_result_is_final({{alice}}, 0) == true, 73570008);
    }
}
// check: EXECUTED

// Now Dave tries to vote. This should not affect the totals because the result has been finalized
//! new-transaction
//! sender: dave
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // dave's signer type added in tx.
      
      Polling::vote(sender, {{alice}}, 0, true);

      // Check that Dave's late vote did not change the result
      let (yes, no) = Polling::get_tally({{alice}}, 0);
      assert(yes == 1, 73570001);
      assert(no == 1, 73570001);
      assert(Polling::get_result_is_final({{alice}}, 0) == true, 73570008);
    }
}
// check: EXECUTED

// Carol creates a second poll that gets index "1" and votes "aye"
//! new-transaction
//! sender: carol
script {
    use 0x42::Polling;
    fun main(sender: &signer){ // carol's signer type added in tx.
      
      let poll_index = Polling::create_poll(sender, {{alice}});
      assert(poll_index == 1, 73570020);

      Polling::vote(sender, {{alice}}, 1, true);

      // Check that Bob's vote was recorded and that voting is still open
      let (yes, no) = Polling::get_tally({{alice}}, 1);
      assert(yes == 1, 73570001);
      assert(no == 0, 73570001);
      assert(Polling::get_result_is_final({{alice}}, 1) == false, 73570003);
    }
}
// check: EXECUTED

