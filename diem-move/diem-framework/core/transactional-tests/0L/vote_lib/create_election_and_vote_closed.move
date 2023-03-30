//# init --validators Alice Bob Carol

// Alice is going to start an election, and create the struct on her account.
// The election will run until for another 10 epochs
// The election will close before then once threshold is reached.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TurnoutTallyDemo;
    fun main(_root: signer, a_sig: signer) {   
      
      TurnoutTallyDemo::init(&a_sig);
      TurnoutTallyDemo::propose_ballot_by_owner(&a_sig, 100, 10);
    }
}
// check: EXECUTED


// Bob votes

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TurnoutTallyDemo;
    use DiemFramework::VoteReceipt;
    use Std::GUID;
    use Std::Option;

    fun main(_root: signer, b_sig: signer) {   
      let next_id = GUID::get_next_creation_num(@Alice);

      let uid = GUID::create_id(@Alice, next_id - 1); // TODO: unclear why it's 2 and not 0
      let result_opt = TurnoutTallyDemo::vote(&b_sig, @Alice, &uid, 22, true);

      let (r, w) = VoteReceipt::get_receipt_data(@Bob, &uid);
      assert!(r == true, 0); // voted in favor
      assert!(w == 22, 1);
      // The Vote does not close and pass immediately. It requires one more vote in favor AT LEAST ONE day later.

      // let (complete, passed) = TurnoutTallyDemo::get_result(@Alice);
      assert!(Option::is_none(&result_opt), 2);
      // assert!(!passed, 3);
    }
}
// check: EXECUTED


//////////////////////////////////////////////
///// Trigger reconfiguration at 61 seconds ////
//# block --proposer Alice --time 61000000 --round 15

///// TEST RECONFIGURATION IS HAPPENING ////
// check: NewEpochEvent
//////////////////////////////////////////////


// NEXT DAY CAROL SENDS A NEW VOTE
// this time it completes and passes.

//# run --admin-script --signers DiemRoot Carol
script {
    use DiemFramework::TurnoutTallyDemo;
    use DiemFramework::VoteReceipt;
    use Std::GUID;
    use Std::Option;

    fun main(_root: signer, c_sig: signer) {   
     let next_id = GUID::get_next_creation_num(@Alice);

      let uid = GUID::create_id(@Alice, next_id - 1); // TODO: unclear why it's 2 and not 0
      let result_opt = TurnoutTallyDemo::vote(&c_sig, @Alice, &uid, 15, true);

      let (r, w) = VoteReceipt::get_receipt_data(@Carol, &uid);
      assert!(r == true, 3); // voted in favor
      assert!(w == 15, 4);

      // Now it completes after the second vote above threshold.

      assert!(Option::is_some(&result_opt), 5);
      assert!(*Option::borrow(&result_opt), 6); // is true

    }
}
// check: EXECUTED