//# init --validators Alice Bob

// Alice is going to start an election, and create the struct on her account.
// Voting ends at the end of epoch 1.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::TurnoutTallyDemo;
    fun main(_root: signer, a_sig: signer) {
      TurnoutTallyDemo::init(&a_sig);

      // ZERO HERE MEANS IT NEVER EXPIRES
      TurnoutTallyDemo::propose_ballot_by_owner(&a_sig, 100, 0);
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
    use DiemFramework::TurnoutTallyDemo;
    use Std::GUID;

    fun main(_root: signer, b_sig: signer) {   
      let next_id = GUID::get_next_creation_num(@Alice);

      let uid = GUID::create_id(@Alice, next_id - 1); // TODO: unclear why it's 2 and not 0
      TurnoutTallyDemo::vote(&b_sig, @Alice, &uid, 22, true);
    }
}
