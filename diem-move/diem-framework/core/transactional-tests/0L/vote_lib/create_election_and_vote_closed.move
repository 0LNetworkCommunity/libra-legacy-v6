//# init --validators Alice Bob

// Alice is going to start an election, and create the struct on her account.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DummyTestVote;
    fun main(_root: signer, a_sig: signer) {   
      DummyTestVote::init(&a_sig,  b"please vote", 100, 10, 0);
    }
}
// check: EXECUTED


// Bob votes

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::DummyTestVote;
    use DiemFramework::ParticipationVote;
    // use DiemFramework::Debug::print;

    fun main(_root: signer, b_sig: signer) {   
      DummyTestVote::vote(&b_sig, @Alice, 22, true);
      let id = DummyTestVote::get_id(@Alice);
      let (r, w) = ParticipationVote::get_receipt_data(@Bob, &id);
      assert!(r == true, 0); // voted in favor
      assert!(w == 22, 1);

      // The Vote does not close and pass immediately. It requires one more vote in favor AT LEAST ONE day later.
      let (complete, passed) = DummyTestVote::get_result(@Alice);
      assert!(!complete, 2);
      assert!(!passed, 3);
    }
}
// check: EXECUTED


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


// NEXT DAY BOB SENDS A NEW VOTE
// this time it completes and passes.

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::DummyTestVote;
    use DiemFramework::ParticipationVote;
    // use DiemFramework::Debug::print;

    fun main(_root: signer, b_sig: signer) {   
      DummyTestVote::vote(&b_sig, @Alice, 2, true);
      let id = DummyTestVote::get_id(@Alice);
      let (r, w) = ParticipationVote::get_receipt_data(@Bob, &id);
      assert!(r == true, 0); // voted in favor
      assert!(w == 2, 1);

      // The Vote does not close and pass immediately. It requires one more vote in favor AT LEAST ONE day later.
      let (complete, passed) = DummyTestVote::get_result(@Alice);
      assert!(complete, 2);
      assert!(passed, 3);
    }
}
// check: EXECUTED