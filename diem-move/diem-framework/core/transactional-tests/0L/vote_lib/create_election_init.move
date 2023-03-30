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
