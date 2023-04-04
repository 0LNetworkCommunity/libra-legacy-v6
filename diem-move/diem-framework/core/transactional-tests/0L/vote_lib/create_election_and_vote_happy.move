//# init --validators Alice Bob

// Alice is going to start an election, and create the struct on her account.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TurnoutTallyDemo;
    fun main(_root: signer, a_sig: signer) {   
      
      TurnoutTallyDemo::init(&a_sig);
      TurnoutTallyDemo::propose_ballot_by_owner(&a_sig, 100, 22);
    }
}
// check: EXECUTED


// Bob votes

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::TurnoutTallyDemo;
    use DiemFramework::VoteReceipt;

    use Std::GUID;
    // use DiemFramework::Debug::print;

    fun main(_root: signer, b_sig: signer) { 
      let next_id = GUID::get_next_creation_num(@Alice);

      let uid = GUID::create_id(@Alice, next_id - 1); // TODO: unclear why it's 2 and not 0
      TurnoutTallyDemo::vote(&b_sig, @Alice, &uid, 22, true);
      // let id = TurnoutTallyDemo::get_id(@Alice);
      // print(&id);
      let (r, w) = VoteReceipt::get_receipt_data(@Bob, &uid);
      assert!(r == true, 0); // voted in favor
      assert!(w == 22, 1);
    }
}
// check: EXECUTED