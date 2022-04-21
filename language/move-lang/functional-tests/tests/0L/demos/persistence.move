///// Setting up the test fixtures for the transactions below. 
///// The tags below create validators alice and bob, giving them 1000000 GAS coins.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator
//! account: carol, 1000000, 0


///// DEMO 1: Happy case, the State resource is initialized to Alice's account, 
///// and can subsequently by written to, and read from.

///// This tag tells the test harness that what follows is a separate transaction 
///// from anything above, and that the sender is alice.

//! new-transaction
//! sender: alice
//! gas-currency: GAS
script {
    use 0x1::PersistenceDemo;
    use 0x1::Debug::print;

    // This sender argument was populated by the test harness with a random 
    // address for `alice`, which can be accessed with sender variable or 
    // the helper `{alice}`
    fun main(alice: signer){ // alice's signer type added in tx.
    //script stuff
      PersistenceDemo::initialize(&alice);
      PersistenceDemo::add_stuff(&alice);

    // our checks
      assert(PersistenceDemo::length(&alice) == 3, 0);
      assert(PersistenceDemo::contains(&alice, 1), 1);
      print(&111);
    }
}

///// The tags with `check` matches to a string in the VM output. Here we are 
///// checking for a correct execution.

//! check: EXECUTED

///// DEMO 2: Abort if an `assert` fails.
///// This will fail because length is actually 3
///// Note: In the test harness the state from the previous transaction is 
///// preserved if executing within the same file (persistence.move).

//! new-transaction
//! sender: alice
//! gas-currency: GAS
script {
    use 0x1::PersistenceDemo;
    fun main(sender: signer){
      assert(PersistenceDemo::length(&sender) == 2, 4);
    }
}

///// Checking the VM output for the string ABORTED

// check: ABORTED


///// DEMO 3: State is not initialized in BOB address
///// this will fail because bob does not have the data struct, and we tried 
///// to operate on it.
///// This is a new transaction.

//! new-transaction
//! sender: bob
//! gas-currency: GAS
script {
    use 0x1::PersistenceDemo;
    fun main(sender: signer){
        PersistenceDemo::add_stuff(&sender);
    }
}

///// Checking the VM output for the string `EXECUTION_FAILURE`

// check: EXECUTION_FAILURE