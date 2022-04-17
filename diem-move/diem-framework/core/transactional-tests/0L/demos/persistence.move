//# init --validators Alice Bob

/// Setting up the test fixtures for the transactions below. 
/// The tags below create validators alice and bob, giving them 1000000 GAS coins.

// Todo: These blocks are failing with error: 
// "Error: Failed to fetch account resource under address 
//  000000000000000000000000000000DD. Has the account been created?"
//
// // Give Alice some money...
// //# run --type-args 0x1::GAS::GAS --signers DesignatedDealer --args @Alice 1000000 x"" x""
// //#     -- 0x1::PaymentScripts::peer_to_peer_with_metadata

// // Give Bob some money...
// //# run --type-args 0x1::XUS::XUS --signers DesignatedDealer --args @Bob 1000000 x"" x""
// //#     -- 0x1::PaymentScripts::peer_to_peer_with_metadata

///// DEMO 1: Happy case, the State resource is initialized to Alice's account, 
///// and can subsequently by written to, and read from.

///// This tag tells the test harness that what follows is a separate transaction 
///// from anything above, and that the sender is alice.

//# run --admin-script --signers DiemRoot Alice
script {
    use DiemFramework::PersistenceDemo;
    use DiemFramework::Debug::print;

    // This sender argument was populated by the test harness with a random 
    // address for `alice`, which can be accessed with sender variable or 
    // the helper `{alice}`
    fun main(_dr: signer, sender: signer){ // alice's signer type added in tx.
        print(&760001);
        PersistenceDemo::initialize(&sender);
        PersistenceDemo::add_stuff(&sender);
        assert!(PersistenceDemo::length(&sender) == 3, 0);
        assert!(PersistenceDemo::contains(&sender, 1), 1);
        print(&760009); // Todo: This line is executed but the test fails, why?
    }
}

///// The tags with `check` matches to a string in the VM output. Here we are 
///// checking for a correct execution.
// check: EXECUTED


// Todo: How to check ABORTED in new diem code?
// 
// ///// DEMO 2: Abort if an `assert` fails.
// ///// This will fail because length is actually 3
// ///// Note: In the test harness the state from the previous transaction is 
// ///// preserved if executing within the same file (persistence.move).

// //# run --admin-script --signers DiemRoot Alice
// script {
//     use DiemFramework::PersistenceDemo;
//     use DiemFramework::Debug::print;

//     fun main(_dr: signer, sender: signer){
//         print(&770001);
//         assert!(PersistenceDemo::length(&sender) == 2, 4);
//         print(&770009);
//     }
// }

// ///// Checking the VM output for the string ABORTED

// // check: ABORTED


// Todo: How to check EXECUTION_FAILURE in new diem code?
// 
// ///// DEMO 3: State is not initialized in BOB address
// ///// this will fail because bob does not have the data struct, and we tried 
// ///// to operate on it.
// ///// This is a new transaction.

// //! new-transaction
// //! sender: bob
// //! gas-currency: GAS
// script {
//     use 0x1::PersistenceDemo;
//     fun main(sender: signer){
//         PersistenceDemo::add_stuff(&sender);
//     }
// }

// ///// Checking the VM output for the string `EXECUTION_FAILURE`

// // check: EXECUTION_FAILURE