//# init --validators Alice Bob

///// Setting up the test fixtures for the transactions below. 
///// The tags below create validators alice and bob, giving them 1000000 GAS coins.

///// DEMO 1: Happy case, the State resource is initialized to Alice's account, 
///// and can subsequently by written to, and read from.

///// This tag tells the test harness that what follows is a separate transaction 
///// from anything above, and that the sender is alice.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::PersistenceDemo;

    // This sender argument was populated by the test harness with a random 
    // address for `alice`, which can be accessed with sender variable or 
    // the helper `{alice}`
    fun main(_dr: signer, sender: signer){ // alice's signer type added in tx.
        //script stuff
        PersistenceDemo::initialize(&sender);
        PersistenceDemo::add_stuff(&sender);

        // our checks
        assert!(PersistenceDemo::length(&sender) == 3, 0);
        assert!(PersistenceDemo::contains(&sender, 1), 1);
    }
}

///// The tags with `check` matches to a string in the VM output. Here we are 
///// checking for a correct execution.
//! check: EXECUTED

///// DEMO 2: Abort if an `assert` fails.
///// This will fail because length is actually 3
///// Note: In the test harness the state from the previous transaction is 
///// preserved if executing within the same file (persistence.move).

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::PersistenceDemo;

    fun main(_dr: signer, sender: signer){
      assert!(PersistenceDemo::length(&sender) == 2, 4);
    }
}
///// Checking the VM output for the string ABORTED
// check: ABORTED


///// DEMO 3: State is not initialized in BOB address
///// this will fail because bob does not have the data struct, and we tried 
///// to operate on it.
///// This is a new transaction.

//# run --admin-script --signers DiemRoot Bob
script {
    use DiemFramework::PersistenceDemo;
  
    fun main(_dr: signer, sender: signer){
        PersistenceDemo::add_stuff(&sender);
    }
}
///// Checking the VM output for the string `EXECUTION_FAILURE`
// check: EXECUTION_FAILURE