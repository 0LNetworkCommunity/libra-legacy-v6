Here we use the Move stdlib testing harness to demonstrate how data persistence works on chain.

The files we will be looking at are:
A Move module for demos:
language/stdlib/modules/0L/Demos.move

Test script for testing the module.
language/move-lang/functional-tests/tests/0L/persistence_demo.move


The Move test runner leverages the Rust test infrastructure (`cargo test`) where we can run all tests, or filenames which match a keyword: e.g `cargo test persist` will run persistence_demo.move.

```
cd language/move-lang/functional-tests/
cargo test persistence
```


## The Demo.move Module

```
address 0x1{
    module PersistenceDemo{
        use Std::Vector;
        use Std::Signer;
        use 0x1::Testnet::is_testnet;
    
        // In Move the types for data storage are `resource struct`. Here a type State is being defined. Once a type is initialized in the global state, the resource is treated as if in-memory on the heap, the libra database is abstracted. The data is namespaced by an "access path" which includes the module name and user address. No special APIs are necessary for reading from the database, except permissioning each function which accesses a given struct, more below.
        resource struct State{
          hist: vector<u8>,
        }

        // For this demo, the `initialize` function writes a PersistenceDemo::State resource at the "sender" address. The access path will be <sender address>/PersistenceDemo/State/
        public fun initialize(sender: &signer){
          // `assert can be used to evaluate a bool and exit the program with an error code, e.g. testing if this is being run in testnet, and throwing error 01.
          assert(is_testnet(), 01);
          // In the actual module, must assert that this is the sender is the association
          move_to<State>(sender, State{ hist: Vector::empty() });
        }

        // To read or write to a Resource Struct an `acquires` tag is needed to permission a function. NOTE all downstream functions will also need permission on that data struct, i.e. need the same `acquires` parameters.
        public fun add_stuff(sender: &signer ) acquires State {
          assert(is_testnet(), 01);

          // Resource Struct state is always "borrowed" and "moved" and generally cannot be copied. A struct can be mutably borrowed, if it is written to, using `borrow_global_mut`. Note the Type State
          let st = borrow_global_mut<State>(Signer::address_of(sender));
          // the `&` as in Rust makes the assignment to a borrowed value. Each Vector operation below with use a st.hist and return it before the next one can execute.
          let s = &mut st.hist;

          // Move has very limited data types. Vector is the most sophisticated and resembles a simplified Rust vector. Can be thought of as an array of a single type.
          Vector::push_back(s, 1);
          Vector::push_back(s, 2);
          Vector::push_back(s, 3);
        }

        // Similar to above, except removing state.
        public fun remove_stuff(sender: &signer) acquires State{
          assert(is_testnet(), 01);
          let st = borrow_global_mut<State>(Signer::address_of(sender));
          let s = &mut st.hist;

          Vector::pop_back<u8>(s);
          Vector::pop_back<u8>(s);
          Vector::remove<u8>(s, 0);
        }

        // Here are examples of read operations. Note the `aquires` here again.
        public fun isEmpty(sender: &signer): bool acquires State {
          assert(is_testnet(), 01);

          // Note this is not a mutable borrow. Read only.
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::is_empty(&st.hist)
        }

        // Showing the Vector::length method
        public fun length(sender: &signer): u64 acquires State{
          assert(is_testnet(), 01);
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::length(&st.hist)
        }

        // Showing the Vector::contains method
        public fun contains(sender: &signer, num: u8): bool acquires State {
          assert(is_testnet(), 01);
          let st = borrow_global<State>(Signer::address_of(sender));
          Vector::contains(&st.hist, &num)
        }
    }
}
```

## A Unit Test for Demo.move module
language/move-lang/functional-tests/tests/0L/persistence_demo.move


```
///// Setting up the test fixtures for the transactions below. The tags below create validators alice and bob, giving them 1000000 GAS coins.

//! account: alice, 1000000, 0, validator
//! account: bob, 1000000, 0, validator


///// DEMO 1: Happy case, the State resource is initialized to Alice's account, and can subsequently by written to, and read from.

///// This tag tells the test harness that what follows is a separate transaction from anything above, and that the sender is alice.

//! new-transaction
//! sender: alice
script {
    use 0x1::PersistenceDemo;

    // This sender argument was populated by the test harness with a random address for `alice`, which can be accessed with sender variable or the helper `{alice}`
    fun main(sender: &signer){ // alice's signer type added in tx.
      PersistenceDemo::initialize(sender);

      PersistenceDemo::add_stuff(sender);
      assert(PersistenceDemo::length(sender) == 3, 0);
      assert(PersistenceDemo::contains(sender, 1), 1);
    }
}

///// The tags with `check` matches to a string in the VM output. Here we are checking for a correct execution.
// check: EXECUTED

///// DEMO 2: Abort if an `assert` fails.
///// This will fail because length is actually 3
///// Note: In the test harness the state from the previous transaction is preserved if executing within the same file (persistence.move).

//! new-transaction
//! sender: alice
script {
    use 0x1::PersistenceDemo;
    fun main(sender: &signer){
      assert(PersistenceDemo::length(sender) == 2, 4);
    }
}

///// Checking the VM output for the string ABORTED

// check: ABORTED


///// DEMO 3: State is not initialized in BOB address
///// this will fail because bob does not have the data struct, and we tried to operate on it.
///// This is a new transaction.

//! new-transaction
//! sender: bob
script {
    use 0x1::PersistenceDemo;
    fun main(sender: &signer){
        PersistenceDemo::add_stuff(sender);
    }
}

///// Checking the VM output for the string `EXECUTION_FAILURE`

// check: EXECUTION_FAILURE
```
