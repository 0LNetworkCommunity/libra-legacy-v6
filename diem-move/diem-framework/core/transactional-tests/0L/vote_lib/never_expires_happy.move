//# init --validators Alice Bob

// Alice is going to start an election, and create the struct on her account.
// Voting ends at the end of epoch 1.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DummyTestVote;
    fun main(_root: signer, a_sig: signer) {
      // ZERO HERE MEANS IT NEVER EXPIRES
      DummyTestVote::init(&a_sig, b"please vote", 100, 0, 0);
    }
}
// check: EXECUTED


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


// Bob votes, and the epoch should be 2 now, and the vote expired at end of 1.

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::DummyTestVote;
    use DiemFramework::ParticipationVote;

    fun main(_root: signer, b_sig: signer) {   
      DummyTestVote::vote(&b_sig, @Alice, 22, true);
      let id = DummyTestVote::get_id(@Alice);
      let (r, w) = ParticipationVote::get_receipt_data(@Bob, &id);
      assert!(r == true, 0); // voted in favor
      assert!(w == 22, 1);
      // TX SHOULD BE REJECTED WITH 300010
    }
}
