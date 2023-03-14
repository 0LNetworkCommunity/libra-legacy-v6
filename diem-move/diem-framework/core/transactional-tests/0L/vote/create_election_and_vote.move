//# init --validators Alice Bob

// Alice is going to start an election, and create the struct on her account.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::DummyTestVote;
    fun main(_root: signer, a_sig: signer) {   
      DummyTestVote::init(&a_sig);
    }
}
// check: EXECUTED


// Bob votes

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::DummyTestVote;
    use DiemFramework::ParticipationVote;


    fun main(_root: signer, b_sig: signer) {   
      DummyTestVote::vote(&b_sig, @Alice, 10, true);
      let id = DummyTestVote::get_id(@Alice);
      let (r, w) = ParticipationVote::get_receipt_data(@Bob, &id);
      assert!(r == true, 0); // voted in favor
      assert!(w == 10, 1);
    }
}
// check: EXECUTED